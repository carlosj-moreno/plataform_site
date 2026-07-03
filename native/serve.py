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
import urllib.parse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

PROXY_PREFIXES = ("/api/", "/media/", "/static/")
PROXY_EXACT = ("/webhook", "/healthz_backend")
HOP = {"connection", "keep-alive", "transfer-encoding", "te", "trailer",
       "upgrade", "proxy-authorization", "proxy-authenticate", "content-length"}

BACKEND_HOST = "127.0.0.1"
BACKEND_PORT = 8000
DIST = ""
# Esquema que este proxy anuncia al backend vía X-Forwarded-Proto. Django lo usa
# (SECURE_PROXY_SSL_HEADER) para saber si el request original llegó por TLS.
# - 'http'  (default): este proxy sirve HTTP plano. NO actives SECURE_SSL_REDIRECT
#   en el backend o entrarás en un bucle de redirección infinito.
# - 'https': úsalo SOLO cuando haya un terminador TLS real por delante (nginx/
#   Caddy/túnel) que ya sirva HTTPS a los clientes.
FORWARDED_PROTO = "http"


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
        body = self.rfile.read(length) if length else None
        headers = {k: v for k, v in self.headers.items() if k.lower() not in HOP and k.lower() != "host"}
        headers["Host"] = f"{BACKEND_HOST}:{BACKEND_PORT}"
        # Reenviar el esquema y la IP del cliente para que el backend aplique bien
        # SECURE_PROXY_SSL_HEADER y la whitelist de IPs del engine.
        headers["X-Forwarded-Proto"] = FORWARDED_PROTO
        client_ip = self.client_address[0] if self.client_address else ""
        prior_xff = self.headers.get("X-Forwarded-For", "")
        headers["X-Forwarded-For"] = f"{prior_xff}, {client_ip}".strip(", ") if prior_xff else client_ip
        try:
            conn = http.client.HTTPConnection(BACKEND_HOST, BACKEND_PORT, timeout=120)
            conn.request(self.command, self.path, body=body, headers=headers)
            resp = conn.getresponse()
            data = resp.read()
        except Exception as e:  # backend caido
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
        conn.close()

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
