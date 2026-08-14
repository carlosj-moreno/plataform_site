#!/usr/bin/env python
"""Servidor local del frontend + reverse-proxy al backend (solo stdlib de Python).

Reemplaza a nginx/Caddy SIN instalar nada de terceros. Sirve el build del SPA
(dist/) y reenvia /api, /media, /static y /webhook al backend Django. Asi todo
queda en el MISMO origen (un solo puerto) y los documentos (/media) cargan bien.

Uso:
    python serve.py --port 8080 --backend 127.0.0.1:8000 --dist <ruta a dist>
"""
import argparse
import http.client
import mimetypes
import os
import threading
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PROXY_PREFIXES = ("/api/", "/media/", "/static/")
PROXY_EXACT = ("/webhook", "/healthz_backend")
HOP = {"connection", "keep-alive", "transfer-encoding", "te", "trailer",
       "upgrade", "proxy-authorization", "proxy-authenticate", "content-length"}

BACKEND_HOST = "127.0.0.1"
BACKEND_PORT = 8000
DIST = ""
# Tope del body proxeado (auditoría B6): evita que un Content-Length enorme
# infle la RAM del proxy leyéndolo entero en memoria. 32 MB cubre subidas de
# documentos/imágenes con margen; por encima se rechaza con 413.
MAX_BODY_BYTES = 32 * 1024 * 1024
# Esquema que este proxy anuncia al backend vía X-Forwarded-Proto. Django lo usa
# (SECURE_PROXY_SSL_HEADER) para saber si el request original llegó por TLS.
# - 'http'  (default): este proxy sirve HTTP plano. NO actives SECURE_SSL_REDIRECT
#   en el backend o entrarás en un bucle de redirección infinito.
# - 'https': úsalo SOLO cuando haya un terminador TLS real por delante (nginx/
#   Caddy/túnel) que ya sirva HTTPS a los clientes.
FORWARDED_PROTO = "http"

# Conexión persistente al backend, UNA por hilo del proxy (ThreadingHTTPServer
# corre cada conexión de cliente en su propio hilo). Reutilizarla en vez de
# abrir/cerrar una por request evita agotar los puertos efímeros de Windows:
# antes cada petición dejaba un puerto en TIME_WAIT ~4 min y bajo carga el rango
# (~16k) se acababa en segundos → WinError 10048 y cascada de 502.
_tls = threading.local()


def _backend_conn():
    conn = getattr(_tls, "conn", None)
    if conn is None:
        conn = http.client.HTTPConnection(BACKEND_HOST, BACKEND_PORT, timeout=120)
        _tls.conn = conn
    return conn


def _drop_backend_conn():
    conn = getattr(_tls, "conn", None)
    if conn is not None:
        try:
            conn.close()
        except Exception:
            pass
        _tls.conn = None


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "bootwa-local/1.0"

    def log_message(self, *a):  # silenciar (los logs van por el redirect del .ps1)
        pass

    def _path(self):
        return urllib.parse.urlsplit(self.path).path

    def _is_proxy(self):
        p = self._path()
        return p in PROXY_EXACT or any(p.startswith(pre) for pre in PROXY_PREFIXES)

    def _proxy(self):
        length = int(self.headers.get("Content-Length", 0) or 0)
        if length > MAX_BODY_BYTES:
            self.send_error(413, "payload demasiado grande")
            return
        body = self.rfile.read(length) if length else None
        headers = {k: v for k, v in self.headers.items() if k.lower() not in HOP and k.lower() != "host"}
        headers["Host"] = f"{BACKEND_HOST}:{BACKEND_PORT}"
        # Reenviar el esquema y la IP del cliente para que el backend aplique bien
        # SECURE_PROXY_SSL_HEADER y la whitelist de IPs del engine.
        headers["X-Forwarded-Proto"] = FORWARDED_PROTO
        client_ip = self.client_address[0] if self.client_address else ""
        prior_xff = self.headers.get("X-Forwarded-For", "")
        headers["X-Forwarded-For"] = f"{prior_xff}, {client_ip}".strip(", ") if prior_xff else client_ip
        # Reutilizamos la conexión persistente del hilo. Si el backend cerró su
        # lado (keep-alive expirado, waitress recicló), el primer intento lanza
        # una excepción de conexión: la descartamos y reabrimos UNA vez. El
        # reintento solo es seguro porque el body ya está en memoria (lo leímos
        # arriba), así que reenviar la misma request es idempotente aquí.
        resp = data = None
        for attempt in (1, 2):
            try:
                conn = _backend_conn()
                conn.request(self.command, self.path, body=body, headers=headers)
                resp = conn.getresponse()
                data = resp.read()
                break
            except Exception as e:  # conexión rota o backend caído
                _drop_backend_conn()
                if attempt == 2:
                    self.send_error(502, f"backend no responde: {e}")
                    return
        self.send_response(resp.status)
        for k, v in resp.getheaders():
            if k.lower() in HOP:
                continue
            self.send_header(k, v)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(data)

    def _static(self):
        rel = urllib.parse.unquote(self._path()).lstrip("/")
        dist_root = os.path.abspath(DIST)
        fs = os.path.abspath(os.path.join(dist_root, rel))
        # anti path-traversal + fallback SPA. Comparamos contra `dist_root + sep`
        # (no solo el prefijo): sin el separador, una ruta hacia un directorio
        # HERMANO cuyo nombre empiece igual (p. ej. `dist-ssr`) pasaría el
        # startswith. El propio dist_root exacto no es un archivo, así que exigir
        # el separador no bloquea ningún caso legítimo.
        if not (fs.startswith(dist_root + os.sep) and os.path.isfile(fs)):
            # /assets/ son archivos con hash de Vite: si no existe es porque un
            # deploy los renombró. Responder 404 limpio (no index.html como si
            # fuera JS) para que el cliente detecte el chunk viejo y recargue.
            if rel.startswith("assets/"):
                self.send_error(404, "asset de un build anterior")
                return
            fs = os.path.join(dist_root, "index.html")
        ctype = mimetypes.guess_type(fs)[0] or "application/octet-stream"
        with open(fs, "rb") as f:
            data = f.read()
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(data)))
        # Headers de seguridad en las respuestas estáticas del SPA.
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "SAMEORIGIN")
        self.send_header("Referrer-Policy", "same-origin")
        if FORWARDED_PROTO == "https":
            self.send_header("Strict-Transport-Security",
                             "max-age=31536000; includeSubDomains")
        if fs.endswith("index.html"):
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        elif rel.startswith("assets/"):
            # El hash en el nombre cambia con cada build: cachear fuerte.
            self.send_header("Cache-Control", "public, max-age=31536000, immutable")
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(data)

    def _handle(self):
        if self._is_proxy():
            self._proxy()
        elif self.command in ("GET", "HEAD"):
            self._static()
        else:
            self.send_error(405)

    do_GET = do_HEAD = do_POST = do_PUT = do_PATCH = do_DELETE = do_OPTIONS = _handle


def main():
    global BACKEND_HOST, BACKEND_PORT, DIST, FORWARDED_PROTO
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8080)
    ap.add_argument("--backend", default="127.0.0.1:8000")
    ap.add_argument("--dist", required=True)
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--forwarded-proto", default="http", choices=["http", "https"],
                    help="Esquema anunciado al backend. Usa 'https' SOLO si hay un "
                         "terminador TLS por delante.")
    args = ap.parse_args()
    BACKEND_HOST, p = args.backend.split(":")
    BACKEND_PORT = int(p)
    FORWARDED_PROTO = args.forwarded_proto
    DIST = os.path.abspath(args.dist)
    if not os.path.isfile(os.path.join(DIST, "index.html")):
        raise SystemExit(f"No existe {DIST}\\index.html (corre deploy.ps1 / build del frontend)")
    httpd = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"Frontend+proxy en http://{args.host}:{args.port}  ->  backend {BACKEND_HOST}:{BACKEND_PORT}")
    httpd.serve_forever()


if __name__ == "__main__":
    main()
