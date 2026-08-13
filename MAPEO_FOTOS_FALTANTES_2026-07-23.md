# Mapeo de fotos de inventario faltantes por carro

**Fecha:** 2026-07-23 · **Fichas analizadas:** 489 (empresas con Inventario Vehicular)

Generado tras correr la recuperación automática (`retomar_fotos_vehiculos --apply`, ya
blindada para no llenar "salida" sin salida anunciada). Todo lo recuperable de los chats
ya quedó adjuntado en la base de datos; lo que aparece aquí como faltante **no existe en
el sistema** y solo se completa si el patio lo reenvía con el caption `*PLACA*`.

## Resumen

| Métrica | Valor |
|---|---|
| Fichas con ingreso completo (12/12) | 8 |
| Fichas con ingreso incompleto | 481 |
| — de ellas, SIN NINGUNA foto de ingreso | 113 |
| Fichas con salida anunciada | 201 |
| — con salida completa (12/12) | 1 |
| Fichas con fotos de "salida" SIN salida anunciada (sospechosas) | 174 |
| Fichas con fotos sueltas en el chat que no encajaron (duplicados de ángulo) | 201 |

Ángulos que más faltan en el ingreso (todo el parque): llaves, repuesto, baúl, interior 3,
kilometraje, interior 2 — el patrón es que los patios fotografían el exterior y omiten
los ángulos internos/accesorios.

## Detalle por carro (ingreso incompleto o salida anunciada incompleta)

Abreviaturas: del=delantera, post=posterior, lat.der/izq=laterales, int1-3=interiores,
rep=repuesto, km=kilometraje. "Sueltas" = fotos de esa placa que siguen en el chat sin
ángulo (duplicados); se pueden asignar a mano desde el hub.

| Placa | Creada | Ingreso | Faltan (ingreso) | Salida | Faltan (salida) | Sueltas |
|---|---|---|---|---|---|---|
| PLACA | CREADA | INGRESO_OK | INGRESO_FALTAN | sin salida | — | SUELTAS_SIN_ENCAJAR |
| FSW622 | 2026-07-02 | 5/12 | lat.izq, motor, int2, int3, rep, km, llaves | sin salida ⚠5 fotos | — | 0 |
| EPP666 | 2026-07-02 | 11/12 | llaves | sin salida ⚠5 fotos | — | 2 |
| JNU280 | 2026-07-02 | 10/12 | rep, llaves | sin salida | — | 0 |
| MXR019 | 2026-07-02 | 11/12 | llaves | sin salida ⚠6 fotos | — | 3 |
| KQM195 | 2026-07-02 | 11/12 | llaves | sin salida ⚠2 fotos | — | 0 |
| IUY843 | 2026-07-02 | 9/12 | lat.izq, int2, int3 | sin salida ⚠4 fotos | — | 4 |
| LWP862 | 2026-07-02 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 9/12 | post, int3, llaves | 0 |
| JPN945 | 2026-07-03 | 11/12 | lat.izq | sin salida | — | 0 |
| KNV490 | 2026-07-03 | 11/12 | llaves | sin salida ⚠1 fotos | — | 0 |
| QEG469 | 2026-07-03 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| IUS310 | 2026-07-03 | 8/12 | int2, int3, rep, llaves | sin salida ⚠2 fotos | — | 0 |
| LXV611 | 2026-07-03 | 8/12 | lat.izq, int3, rep, llaves | sin salida ⚠3 fotos | — | 1 |
| KTV634 | 2026-07-06 | 11/12 | int2 | sin salida ⚠2 fotos | — | 0 |
| LWS138 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| PFI987 | 2026-07-09 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| RIU667 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| TEO517 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KZM955 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HKV859 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| TLZ692 | 2026-07-09 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LTO840 | 2026-07-09 | 8/12 | motor, baul, rep, km | sin salida ⚠3 fotos | — | 2 |
| KHV090 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| NYP763 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| MNW043 | 2026-07-09 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| GKU696 | 2026-07-14 | 7/12 | lat.izq, int3, baul, rep, llaves | sin salida ⚠2 fotos | — | 2 |
| MVK686 | 2026-07-14 | 9/12 | del, lat.izq, km | sin salida | — | 0 |
| MVL290 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 8/12 | lat.izq, int3, rep, km | 0 |
| WOM124 | 2026-07-14 | 4/12 | lat.izq, motor, int1, int2, int3, baul, rep, llaves | 8/12 | lat.izq, int2, int3, baul | 0 |
| IRS130 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| GQV295 | 2026-07-14 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| MKT375 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| DVM207 | 2026-07-14 | 1/12 | del, post, lat.der, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 3 |
| LVX592 | 2026-07-14 | 3/12 | post, lat.izq, motor, int2, int3, baul, rep, km, llaves | 8/12 | motor, int2, int3, llaves | 1 |
| FXY149 | 2026-07-14 | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| EXV517 | 2026-07-14 | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 7/12 | int3, baul, rep, km, llaves | 1 |
| KZX137 | 2026-07-14 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LLM818 | 2026-07-14 | 6/12 | int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 1 |
| LLM464 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 6/12 | del, lat.izq, int3, rep, km, llaves | 1 |
| PMW754 | 2026-07-14 | 9/12 | int3, baul, llaves | sin salida ⚠1 fotos | — | 1 |
| GKU887 | 2026-07-14 | 9/12 | lat.izq, baul, llaves | sin salida ⚠3 fotos | — | 1 |
| KSM613 | 2026-07-14 | 4/12 | del, post, lat.der, lat.izq, motor, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| LJK684 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 10/12 | rep, llaves | 0 |
| NUM102 | 2026-07-14 | 11/12 | llaves | sin salida | — | 0 |
| MHY878 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km | sin salida | — | 0 |
| DAW776 | 2026-07-14 | 8/12 | del, int2, int3, rep | sin salida | — | 3 |
| LHO820 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| EPB563 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| DAS431 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | baul | 1 |
| EBT059 | 2026-07-14 | 11/12 | rep | sin salida ⚠1 fotos | — | 2 |
| LGV334 | 2026-07-14 | 11/12 | baul | sin salida ⚠2 fotos | — | 0 |
| LZR992 | 2026-07-14 | 9/12 | int3, baul, rep | sin salida ⚠5 fotos | — | 4 |
| NWN494 | 2026-07-14 | 6/12 | lat.izq, int3, baul, rep, km, llaves | sin salida ⚠2 fotos | — | 4 |
| DAX214 | 2026-07-14 | 10/12 | int3, llaves | sin salida ⚠3 fotos | — | 1 |
| NPY363 | 2026-07-14 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| NFN791 | 2026-07-14 | 3/12 | del, lat.der, lat.izq, motor, int1, int2, int3, km, llaves | sin salida ⚠1 fotos | — | 0 |
| LUN069 | 2026-07-14 | 3/12 | lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 8/12 | motor, baul, km, llaves | 4 |
| XWD385T | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| XWD385 | 2026-07-14 | 8/12 | baul, rep, km, llaves | sin salida ⚠3 fotos | — | 2 |
| LTX778 | 2026-07-14 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 3 |
| JTV551 | 2026-07-14 | 8/12 | int3, rep, km, llaves | sin salida ⚠3 fotos | — | 5 |
| KSV486 | 2026-07-14 | 5/12 | motor, int2, int3, baul, rep, km, llaves | sin salida | — | 5 |
| IRQ270 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| GPS787 | 2026-07-14 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠2 fotos | — | 0 |
| KYT458 | 2026-07-14 | 6/12 | motor, int1, int2, int3, rep, km | sin salida ⚠1 fotos | — | 0 |
| JNL898 | 2026-07-14 | 8/12 | lat.izq, baul, km, llaves | sin salida ⚠4 fotos | — | 1 |
| HWZ985 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| FZO734 | 2026-07-14 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 1 |
| NIO910 | 2026-07-14 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| NMW520 | 2026-07-14 | 5/12 | del, post, lat.der, lat.izq, motor, baul, llaves | sin salida | — | 0 |
| GFP182 | 2026-07-14 | 3/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, llaves | 8/12 | lat.izq, int2, int3, rep | 1 |
| KPN431 | 2026-07-14 | 7/12 | lat.der, lat.izq, rep, km, llaves | sin salida ⚠3 fotos | — | 4 |
| EJY840 | 2026-07-14 | 8/12 | lat.der, lat.izq, rep, llaves | sin salida ⚠4 fotos | — | 3 |
| JPP788 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| EGZ536 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km | sin salida | — | 0 |
| HWT245 | 2026-07-14 | 8/12 | int2, int3, baul, llaves | 2/12 | del, lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 4 |
| FSY420 | 2026-07-14 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 3 |
| KPR465 | 2026-07-14 | 8/12 | lat.der, baul, km, llaves | sin salida ⚠2 fotos | — | 1 |
| GFK476 | 2026-07-14 | 10/12 | baul, rep | sin salida ⚠3 fotos | — | 1 |
| NQP225 | 2026-07-14 | 4/12 | del, lat.der, lat.izq, motor, int2, int3, rep, llaves | sin salida | — | 1 |
| EYZ050 | 2026-07-14 | 3/12 | del, lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 10/12 | km, llaves | 1 |
| PCQ524 | 2026-07-14 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| JUW629 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| NQO372 | 2026-07-14 | 11/12 | llaves | sin salida ⚠3 fotos | — | 0 |
| INK376 | 2026-07-14 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KTK038 | 2026-07-14 | 3/12 | post, lat.izq, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| MVM881 | 2026-07-14 | 10/12 | baul, rep | sin salida ⚠3 fotos | — | 0 |
| HDO732 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | int2, baul, km | 0 |
| LJK11D | 2026-07-14 | 5/12 | motor, int1, int2, int3, baul, rep, llaves | sin salida ⚠1 fotos | — | 0 |
| LOX962 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| FUU796 | 2026-07-14 | 8/12 | motor, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| HET528 | 2026-07-14 | 10/12 | km, llaves | sin salida ⚠1 fotos | — | 0 |
| HUY908 | 2026-07-14 | 4/12 | del, lat.der, lat.izq, int1, int2, int3, km, llaves | sin salida | — | 0 |
| KKD845 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 9/12 | baul, km, llaves | 0 |
| JZZ601 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LJK406 | 2026-07-14 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km | sin salida | — | 0 |
| LXP46G | 2026-07-14 | 5/12 | int1, int2, int3, baul, rep, km, llaves | 4/12 | del, int1, int2, int3, baul, rep, km, llaves | 9 |
| LWS943 | 2026-07-14 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 9/12 | int3, baul, llaves | 0 |
| KQL443 | 2026-07-14 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 2 |
| LWS399 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, km, llaves | 10/12 | baul, llaves | 0 |
| JLK555 | 2026-07-14 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| IRR747 | 2026-07-14 | 4/12 | lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 9/12 | motor, int3, llaves | 4 |
| BRR379 | 2026-07-14 | 2/12 | del, lat.der, lat.izq, motor, int1, int3, baul, rep, km, llaves | 11/12 | baul | 0 |
| FSY354 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| JTZ404 | 2026-07-14 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| JVR642 | 2026-07-14 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| RBZ932 | 2026-07-14 | 10/12 | baul, llaves | sin salida ⚠4 fotos | — | 2 |
| MDH92H | 2026-07-14 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 1 |
| MIQ022 | 2026-07-15 | 3/12 | del, lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 11/12 | km | 0 |
| MIS709 | 2026-07-15 | 5/12 | del, lat.izq, int2, int3, baul, km, llaves | 9/12 | baul, rep, km | 1 |
| LCL205 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| NBY707 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| JCT926 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| EHZ246 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| MBY411 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| GFK344 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LNM340 | 2026-07-15 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| XEI14F | 2026-07-15 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 5/12 | int1, int2, int3, baul, rep, km, llaves | 0 |
| IJW064 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LWU251 | 2026-07-15 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| DUZ000 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| IUT416 | 2026-07-15 | 7/12 | lat.der, lat.izq, int3, km, llaves | sin salida ⚠3 fotos | — | 8 |
| HWL299 | 2026-07-15 | 4/12 | lat.der, lat.izq, int1, int2, int3, baul, km, llaves | 11/12 | km | 5 |
| JOT438 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 12/12 | — | 0 |
| KVQ278 | 2026-07-15 | 4/12 | del, post, lat.izq, motor, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| JLN651 | 2026-07-15 | 10/12 | baul, llaves | sin salida ⚠3 fotos | — | 2 |
| HRQ422 | 2026-07-15 | 9/12 | rep, km, llaves | sin salida ⚠2 fotos | — | 1 |
| FXX252 | 2026-07-15 | 5/12 | lat.der, lat.izq, motor, baul, rep, km, llaves | sin salida | — | 1 |
| NOR476 | 2026-07-15 | 10/12 | int3, rep | sin salida ⚠2 fotos | — | 3 |
| LZL992 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KSY794 | 2026-07-15 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, llaves | 11/12 | llaves | 0 |
| GQV179 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 8/12 | motor, baul, rep, llaves | 2 |
| JDY584 | 2026-07-15 | 9/12 | baul, rep, llaves | sin salida ⚠2 fotos | — | 1 |
| QJX283 | 2026-07-15 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KVZ823 | 2026-07-15 | 11/12 | llaves | 6/12 | lat.izq, int2, int3, baul, rep, llaves | 10 |
| FZL415 | 2026-07-15 | 11/12 | baul | sin salida | — | 0 |
| LIY460 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KMK132 | 2026-07-15 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| EOL622 | 2026-07-15 | 10/12 | rep, llaves | sin salida ⚠3 fotos | — | 2 |
| LKP464 | 2026-07-15 | 11/12 | rep | sin salida ⚠3 fotos | — | 1 |
| NQS582 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LCU707 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KTM897 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| FVQ550 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KOO178 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| UEL177 | 2026-07-15 | 11/12 | motor | sin salida ⚠3 fotos | — | 2 |
| GEP266 | 2026-07-15 | 11/12 | rep | sin salida ⚠2 fotos | — | 1 |
| GEL528 | 2026-07-15 | 11/12 | int3 | sin salida ⚠2 fotos | — | 1 |
| IYN563 | 2026-07-15 | 9/12 | baul, km, llaves | sin salida ⚠3 fotos | — | 2 |
| JYZ714 | 2026-07-15 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LPL009 | 2026-07-15 | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 8/12 | motor, baul, rep, llaves | 4 |
| YZX51F | 2026-07-16 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 1 |
| BWF233 | 2026-07-16 | 9/12 | baul, rep, llaves | sin salida ⚠3 fotos | — | 1 |
| TZQ061 | 2026-07-16 | 4/12 | lat.der, lat.izq, int2, int3, baul, rep, km, llaves | sin salida ⚠4 fotos | — | 6 |
| EGO804 | 2026-07-16 | 8/12 | lat.der, lat.izq, rep, llaves | sin salida ⚠4 fotos | — | 1 |
| NBM489 | 2026-07-16 | 11/12 | llaves | sin salida | — | 0 |
| NHR009 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| CRK768 | 2026-07-16 | 11/12 | rep | sin salida ⚠2 fotos | — | 2 |
| MVN253 | 2026-07-16 | 11/12 | rep | sin salida ⚠2 fotos | — | 0 |
| RCX62E | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LIM818 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| GKV887 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HIT435 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KWF63H | 2026-07-16 | 5/12 | motor, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 1 |
| CKJ008 | 2026-07-16 | 6/12 | lat.izq, int3, baul, rep, km, llaves | sin salida ⚠3 fotos | — | 2 |
| JJS163 | 2026-07-16 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | rep, llaves | 3 |
| FVN519 | 2026-07-16 | 10/12 | km, llaves | 5/12 | post, int2, int3, baul, rep, km, llaves | 1 |
| KWS933 | 2026-07-16 | 11/12 | rep | sin salida ⚠2 fotos | — | 0 |
| JGL001 | 2026-07-16 | 7/12 | lat.izq, int3, baul, km, llaves | sin salida ⚠2 fotos | — | 0 |
| EBR098 | 2026-07-16 | 11/12 | rep | sin salida ⚠3 fotos | — | 0 |
| GFO127 | 2026-07-16 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| FZQ313 | 2026-07-16 | 10/12 | rep, llaves | sin salida ⚠3 fotos | — | 0 |
| XEX70F | 2026-07-16 | 2/12 | del, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KQX740 | 2026-07-16 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 9/12 | int3, baul, llaves | 0 |
| LLV227 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| FJL662 | 2026-07-16 | 4/12 | lat.der, lat.izq, motor, int2, int3, rep, km, llaves | 6/12 | lat.der, lat.izq, motor, int3, rep, llaves | 3 |
| LJL110 | 2026-07-16 | 11/12 | int3 | sin salida | — | 0 |
| MHZ66B | 2026-07-16 | 1/12 | del, post, lat.der, motor, int1, int2, int3, baul, rep, km, llaves | 3/12 | del, motor, int1, int2, int3, baul, rep, km, llaves | 3 |
| LYW309 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 3 |
| PGM064 | 2026-07-16 | 9/12 | baul, km, llaves | sin salida ⚠4 fotos | — | 4 |
| MPT209 | 2026-07-16 | 10/12 | baul, llaves | sin salida ⚠3 fotos | — | 1 |
| GRM108 | 2026-07-16 | 11/12 | int3 | sin salida ⚠1 fotos | — | 1 |
| WNO462 | 2026-07-16 | 8/12 | int3, rep, km, llaves | 9/12 | baul, rep, llaves | 5 |
| DRL884 | 2026-07-16 | 10/12 | baul, llaves | sin salida ⚠3 fotos | — | 2 |
| DLQ30H | 2026-07-16 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 5/12 | motor, int1, int2, int3, baul, rep, llaves | 0 |
| WLV855 | 2026-07-16 | 6/12 | post, motor, baul, rep, km, llaves | sin salida ⚠2 fotos | — | 0 |
| WLU855 | 2026-07-16 | 9/12 | lat.der, km, llaves | sin salida ⚠4 fotos | — | 0 |
| TGY097 | 2026-07-16 | 9/12 | baul, rep, llaves | sin salida ⚠2 fotos | — | 1 |
| YAJ58F | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KQW138 | 2026-07-16 | 10/12 | rep, llaves | sin salida ⚠1 fotos | — | 0 |
| DGV356 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LYR688 | 2026-07-16 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 0 |
| JRW312 | 2026-07-16 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| EPQ970 | 2026-07-16 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| PXW666 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| POR522 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| JOS638 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| EGU635 | 2026-07-16 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | lat.izq, llaves | 0 |
| MVU074 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| EQS150 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LLZ233 | 2026-07-16 | 9/12 | baul, km, llaves | 5/12 | post, lat.izq, motor, int3, rep, km, llaves | 1 |
| GRV577 | 2026-07-16 | 2/12 | del, post, lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 10/12 | int3, llaves | 0 |
| JFN642 | 2026-07-16 | 8/12 | int2, int3, rep, llaves | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4 |
| LMN543 | 2026-07-16 | 10/12 | rep, llaves | 3/12 | post, lat.der, lat.izq, motor, int2, int3, baul, rep, llaves | 1 |
| JHR229 | 2026-07-16 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | rep, km, llaves | 0 |
| LST823 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| FIT460 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| HSL834 | 2026-07-16 | 10/12 | int3, rep | sin salida ⚠1 fotos | — | 0 |
| KQV513 | 2026-07-16 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, km, llaves | 10/12 | post, llaves | 0 |
| HEO968 | 2026-07-16 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, rep, km, llaves | 10/12 | motor, rep | 0 |
| JMY355 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| JPP789 | 2026-07-16 | 8/12 | motor, baul, rep, llaves | sin salida ⚠1 fotos | — | 0 |
| LRW643 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LCP808 | 2026-07-16 | 11/12 | llaves | sin salida ⚠1 fotos | — | 0 |
| AQD137 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| NNO004 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| HEL299 | 2026-07-16 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| GFV588 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| HDW651 | 2026-07-16 | 9/12 | lat.izq, int2, int3 | sin salida ⚠3 fotos | — | 1 |
| LJK449 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| RJU668 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| JYU593 | 2026-07-16 | 11/12 | baul | sin salida ⚠3 fotos | — | 2 |
| RBP802 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LYQ192 | 2026-07-16 | 11/12 | llaves | sin salida ⚠1 fotos | — | 0 |
| GGK344 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| NTY238 | 2026-07-16 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| DDW916 | 2026-07-16 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 3/12 | lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1 |
| KRZ201 | 2026-07-17 | 5/12 | lat.izq, int1, int2, int3, baul, km, llaves | 11/12 | llaves | 3 |
| KCG16F | 2026-07-17 | 5/12 | int1, int2, int3, baul, rep, km, llaves | sin salida ⚠5 fotos | — | 4 |
| LRR280 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| HAW023 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KTR892 | 2026-07-17 | 2/12 | post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | lat.izq, int3, llaves | 2 |
| ENU185 | 2026-07-17 | 7/12 | lat.der, lat.izq, int2, int3, llaves | sin salida ⚠3 fotos | — | 5 |
| JWQ580 | 2026-07-17 | 10/12 | lat.izq, baul | 11/12 | lat.izq | 9 |
| DRW722 | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LVW355 | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LW355 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LGL905 | 2026-07-17 | 11/12 | rep | sin salida ⚠2 fotos | — | 3 |
| LZZ161 | 2026-07-17 | 11/12 | rep | sin salida ⚠4 fotos | — | 1 |
| JYZ449 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KJH661 | 2026-07-17 | 11/12 | llaves | sin salida | — | 0 |
| PMW492 | 2026-07-17 | 10/12 | rep, llaves | sin salida ⚠3 fotos | — | 0 |
| KQN829 | 2026-07-17 | 9/12 | lat.izq, rep, llaves | sin salida ⚠3 fotos | — | 0 |
| FWT326 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 2 |
| ENK693 | 2026-07-17 | 1/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, llaves | 9/12 | int2, int3, llaves | 0 |
| GXY199 | 2026-07-17 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 2 |
| IPX999 | 2026-07-17 | 3/12 | lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 9/12 | lat.der, lat.izq, llaves | 2 |
| MGV928 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| WDK574 | 2026-07-17 | 5/12 | lat.der, lat.izq, int2, int3, baul, rep, km | 8/12 | lat.der, lat.izq, motor, llaves | 2 |
| JPK385 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| DQC52G | 2026-07-17 | 2/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, llaves | 3/12 | post, motor, int1, int2, int3, baul, rep, km, llaves | 1 |
| XMD366 | 2026-07-17 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 6/12 | lat.izq, int2, baul, rep, km, llaves | 3 |
| DVK749 | 2026-07-17 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, llaves | 11/12 | llaves | 0 |
| LIU651 | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| DSV536 | 2026-07-17 | 8/12 | lat.izq, int3, km, llaves | 2/12 | post, lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 1 |
| TJP299 | 2026-07-17 | 10/12 | motor, llaves | sin salida ⚠3 fotos | — | 0 |
| ZRM35F | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HEV378 | 2026-07-17 | 9/12 | lat.izq, int3, llaves | 5/12 | lat.der, lat.izq, int2, int3, baul, km, llaves | 2 |
| TRI914 | 2026-07-17 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| MXK456 | 2026-07-17 | 6/12 | lat.izq, int1, int2, int3, km, llaves | 3/12 | lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4 |
| JHT002 | 2026-07-17 | 9/12 | int3, baul, rep | sin salida ⚠3 fotos | — | 3 |
| NGU261 | 2026-07-17 | 3/12 | del, lat.der, lat.izq, int1, int2, int3, baul, rep, llaves | 11/12 | int3 | 0 |
| ESR716 | 2026-07-17 | 9/12 | baul, rep, llaves | 11/12 | baul | 17 |
| LTZ571 | 2026-07-17 | 2/12 | post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| ICT374 | 2026-07-17 | 3/12 | lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 8/12 | lat.der, lat.izq, km, llaves | 4 |
| IEU91D | 2026-07-17 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 1 |
| HGN292 | 2026-07-17 | 1/12 | del, post, lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 10/12 | km, llaves | 0 |
| UEO648 | 2026-07-17 | 2/12 | del, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| ISV094 | 2026-07-17 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 8/12 | lat.izq, rep, km, llaves | 0 |
| MUW392 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| MVZ343 | 2026-07-17 | 6/12 | motor, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 1 |
| DZI115 | 2026-07-17 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| LMM601 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| LEL222 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| WDE591 | 2026-07-17 | 8/12 | lat.izq, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| KXL978 | 2026-07-17 | 9/12 | int3, baul, llaves | sin salida ⚠3 fotos | — | 1 |
| WMK567 | 2026-07-17 | 9/12 | rep, km, llaves | sin salida ⚠3 fotos | — | 0 |
| EFP539 | 2026-07-17 | 11/12 | llaves | sin salida ⚠1 fotos | — | 0 |
| NGL793 | 2026-07-17 | 3/12 | lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 10/12 | int3, rep | 6 |
| BPQ578 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| JYO272 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| NGV966 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LUN321 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| EPC27H | 2026-07-17 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠3 fotos | — | 6 |
| KVW883 | 2026-07-17 | 9/12 | lat.izq, int3, baul | sin salida ⚠2 fotos | — | 1 |
| DUR119 | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | baul | 1 |
| WNL14F | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| DMX983 | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| JYY844 | 2026-07-17 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| LZO692 | 2026-07-17 | 9/12 | int3, baul, llaves | 8/12 | baul, rep, km, llaves | 7 |
| GKY448 | 2026-07-17 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km | sin salida | — | 0 |
| URR782 | 2026-07-17 | 2/12 | del, post, lat.der, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| KYT714 | 2026-07-17 | 3/12 | del, lat.izq, motor, int2, int3, baul, rep, km, llaves | 9/12 | int3, baul, llaves | 2 |
| JCY433 | 2026-07-17 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| MVM073 | 2026-07-18 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| GZK522 | 2026-07-18 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| XVP062 | 2026-07-18 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| EJR730 | 2026-07-21 | 9/12 | int3, baul, llaves | sin salida ⚠4 fotos | — | 2 |
| KPU255 | 2026-07-21 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LFZ129 | 2026-07-21 | 9/12 | int2, int3, llaves | sin salida ⚠3 fotos | — | 4 |
| GSZ418 | 2026-07-21 | 10/12 | baul, km | sin salida ⚠3 fotos | — | 1 |
| KRX790 | 2026-07-21 | 11/12 | int3 | sin salida ⚠2 fotos | — | 0 |
| LGP488 | 2026-07-21 | 7/12 | del, lat.der, lat.izq, motor, rep | sin salida ⚠2 fotos | — | 3 |
| PYY541 | 2026-07-21 | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HYR884 | 2026-07-21 | 10/12 | lat.izq, rep | sin salida ⚠3 fotos | — | 0 |
| FHI923 | 2026-07-21 | 9/12 | del, rep, llaves | sin salida | — | 0 |
| ENO180 | 2026-07-21 | 5/12 | del, lat.izq, motor, int3, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| NDU670 | 2026-07-21 | 10/12 | rep, llaves | sin salida ⚠1 fotos | — | 0 |
| LIY794 | 2026-07-21 | 11/12 | llaves | sin salida | — | 0 |
| DRZ910 | 2026-07-21 | 10/12 | rep, llaves | sin salida ⚠3 fotos | — | 0 |
| LXV835 | 2026-07-21 | 11/12 | km | sin salida ⚠1 fotos | — | 1 |
| JSO360 | 2026-07-21 | 10/12 | baul, rep | sin salida ⚠1 fotos | — | 2 |
| KYY444 | 2026-07-21 | 11/12 | baul | sin salida ⚠3 fotos | — | 0 |
| LQS322 | 2026-07-21 | 8/12 | lat.izq, int3, km, llaves | sin salida ⚠5 fotos | — | 3 |
| HQK553 | 2026-07-21 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠2 fotos | — | 1 |
| NUQ758 | 2026-07-21 | 2/12 | del, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 7/12 | motor, int3, baul, km, llaves | 5 |
| BWB168 | 2026-07-21 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 1 |
| OEX63E | 2026-07-21 | 5/12 | motor, int1, int2, int3, baul, rep, llaves | sin salida ⚠1 fotos | — | 2 |
| WOM770 | 2026-07-21 | 5/12 | post, int2, int3, baul, rep, km, llaves | 4/12 | del, lat.der, lat.izq, motor, int2, int3, baul, rep | 2 |
| JYU593T | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LGL905T | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| GRM108T | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| IXO871 | 2026-07-21 | 10/12 | int3, llaves | sin salida ⚠3 fotos | — | 0 |
| HWN389 | 2026-07-21 | 10/12 | int3, km | sin salida | — | 1 |
| RZW678 | 2026-07-21 | 9/12 | lat.der, lat.izq, motor | sin salida ⚠3 fotos | — | 2 |
| KOK213 | 2026-07-21 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠2 fotos | — | 4 |
| KEQ762 | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HLH43F | 2026-07-21 | 5/12 | int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| MCL871 | 2026-07-21 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 0 |
| VEJ515 | 2026-07-21 | 7/12 | motor, baul, rep, km, llaves | sin salida | — | 0 |
| HTY114 | 2026-07-21 | 10/12 | rep, llaves | sin salida ⚠1 fotos | — | 1 |
| UQR151 | 2026-07-21 | 7/12 | motor, baul, rep, km, llaves | sin salida | — | 1 |
| ZYZ816 | 2026-07-21 | 6/12 | post, lat.der, lat.izq, baul, rep, llaves | 9/12 | int3, baul, llaves | 3 |
| DUW156 | 2026-07-21 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| CWF050 | 2026-07-21 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 0 |
| EGW003 | 2026-07-21 | 3/12 | lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | 9/12 | lat.izq, rep, llaves | 3 |
| FSK717 | 2026-07-21 | 10/12 | rep, llaves | sin salida ⚠1 fotos | — | 0 |
| WDY597 | 2026-07-21 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LSX031 | 2026-07-21 | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 7/12 | int3, baul, rep, km, llaves | 5 |
| JZV075 | 2026-07-21 | 3/12 | lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | lat.der, lat.izq, llaves | 2 |
| LLO282 | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | km, llaves | 0 |
| QWP68G | 2026-07-21 | 5/12 | int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| LIS302 | 2026-07-21 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, llaves | 10/12 | km, llaves | 0 |
| UWQ769 | 2026-07-21 | 10/12 | int3, rep | sin salida ⚠3 fotos | — | 0 |
| KUY253 | 2026-07-21 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| KXY321 | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LEX748 | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LFX748 | 2026-07-21 | 10/12 | int3, llaves | sin salida ⚠3 fotos | — | 4 |
| KRK483 | 2026-07-21 | 3/12 | lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 10/12 | int3, llaves | 2 |
| JUS668 | 2026-07-21 | 2/12 | del, post, lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 6/12 | motor, int2, int3, rep, km, llaves | 0 |
| NGU85A | 2026-07-21 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 1 |
| NFU21G | 2026-07-21 | 4/12 | lat.izq, motor, int1, int2, int3, baul, rep, llaves | sin salida ⚠1 fotos | — | 2 |
| UEL208 | 2026-07-21 | 11/12 | rep | sin salida ⚠2 fotos | — | 0 |
| LEN158 | 2026-07-21 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KVM711 | 2026-07-21 | 3/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km | 6/12 | lat.izq, motor, int3, baul, rep, llaves | 4 |
| FVY465 | 2026-07-21 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| MWP476 | 2026-07-22 | 10/12 | rep, llaves | 2/12 | del, post, lat.der, lat.izq, int1, int2, int3, rep, km, llaves | 0 |
| TZO597 | 2026-07-22 | 8/12 | lat.der, lat.izq, int2, int3 | sin salida ⚠2 fotos | — | 7 |
| KWT505 | 2026-07-22 | 8/12 | lat.der, lat.izq, baul, rep | sin salida ⚠3 fotos | — | 3 |
| UUN410 | 2026-07-22 | 10/12 | rep, llaves | sin salida ⚠3 fotos | — | 2 |
| NIK396 | 2026-07-22 | 10/12 | int3, llaves | sin salida ⚠2 fotos | — | 0 |
| JYZ461 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LLS218 | 2026-07-22 | 2/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, km, llaves | 9/12 | int1, rep, llaves | 1 |
| GMZ873 | 2026-07-22 | 11/12 | llaves | 3/12 | del, post, lat.der, int1, int2, int3, baul, km, llaves | 0 |
| NQQ205 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LTN128 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| FJQ042 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| KZK606 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| JTV335 | 2026-07-22 | 3/12 | lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | motor, rep, llaves | 3 |
| EBQ363 | 2026-07-22 | 2/12 | post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| EIN502 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| VEZ572 | 2026-07-22 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| ESK756 | 2026-07-22 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| T20591 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HWE30G | 2026-07-22 | 3/12 | lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 1 |
| NQO205 | 2026-07-22 | 9/12 | int3, rep, llaves | sin salida ⚠5 fotos | — | 1 |
| LCP939 | 2026-07-22 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| GWM905 | 2026-07-22 | 8/12 | lat.der, lat.izq, km, llaves | sin salida ⚠3 fotos | — | 4 |
| BXO302 | 2026-07-22 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 7/12 | int3, baul, rep, km, llaves | 6 |
| DOR565 | 2026-07-22 | 6/12 | lat.der, lat.izq, motor, baul, rep, llaves | sin salida ⚠2 fotos | — | 1 |
| AXL566 | 2026-07-22 | 9/12 | baul, rep, llaves | sin salida ⚠5 fotos | — | 2 |
| LKR527 | 2026-07-22 | 11/12 | rep | sin salida ⚠2 fotos | — | 3 |
| WNP911 | 2026-07-22 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| NTY012 | 2026-07-22 | 9/12 | baul, rep, llaves | sin salida ⚠2 fotos | — | 2 |
| HHL546 | 2026-07-22 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 9/12 | lat.izq, km, llaves | 5 |
| IVQ560 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| HFP34G | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| EHO705 | 2026-07-22 | 2/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, rep, llaves | 8/12 | motor, int3, rep, llaves | 0 |
| UUW785 | 2026-07-22 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, rep, km, llaves | 8/12 | lat.izq, baul, km, llaves | 0 |
| MBZ54H | 2026-07-22 | 2/12 | del, post, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| NTR268 | 2026-07-22 | 11/12 | motor | sin salida ⚠4 fotos | — | 0 |
| NLS494 | 2026-07-22 | 10/12 | int3, rep | sin salida ⚠1 fotos | — | 2 |
| KMS788 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| GVY655 | 2026-07-22 | 2/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | int3 | 0 |
| JTU654 | 2026-07-22 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | lat.izq, llaves | 1 |
| KQX654 | 2026-07-22 | 7/12 | lat.izq, int2, int3, baul, llaves | sin salida ⚠3 fotos | — | 2 |
| UIA087 | 2026-07-22 | 8/12 | lat.der, lat.izq, baul, llaves | sin salida ⚠3 fotos | — | 3 |
| IPQ110 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | baul, km | 0 |
| SMH621 | 2026-07-22 | 2/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, km, llaves | 9/12 | baul, km, llaves | 2 |
| BIR29D | 2026-07-22 | 4/12 | lat.izq, motor, int1, int2, int3, baul, rep, llaves | sin salida ⚠1 fotos | — | 2 |
| JVT263 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | rep, llaves | 2 |
| JUP427 | 2026-07-22 | 9/12 | int3, baul, llaves | sin salida ⚠1 fotos | — | 1 |
| NGX066 | 2026-07-22 | 11/12 | motor | sin salida ⚠1 fotos | — | 1 |
| LRM515 | 2026-07-22 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| SQM151 | 2026-07-22 | 8/12 | int1, int2, baul, llaves | sin salida ⚠3 fotos | — | 3 |
| JQS824 | 2026-07-22 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠1 fotos | — | 0 |
| GZK561 | 2026-07-22 | 7/12 | lat.izq, baul, rep, km, llaves | 5/12 | motor, int1, int2, int3, baul, km, llaves | 1 |
| NHX872 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LGV112 | 2026-07-22 | 6/12 | lat.izq, int2, int3, baul, km, llaves | 9/12 | baul, rep, km | 0 |
| KZX074 | 2026-07-22 | 2/12 | del, post, lat.der, lat.izq, motor, int2, int3, rep, km, llaves | 8/12 | baul, rep, km, llaves | 0 |
| NFM396 | 2026-07-22 | 4/12 | lat.izq, int1, int2, int3, baul, rep, km, llaves | 10/12 | int3, llaves | 1 |
| FYX659 | 2026-07-22 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| JVW340 | 2026-07-22 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 10/12 | int3, llaves | 1 |
| IVS956 | 2026-07-22 | 7/12 | post, motor, baul, rep, llaves | sin salida ⚠2 fotos | — | 0 |
| FZT549 | 2026-07-22 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 11/12 | llaves | 0 |
| KST856 | 2026-07-22 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 3/12 | post, lat.izq, motor, int1, int2, int3, baul, rep, km | 0 |
| KSM860 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | rep, llaves | 0 |
| KZS866 | 2026-07-22 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 8/12 | int2, int3, baul, llaves | 3 |
| GHL199 | 2026-07-22 | 9/12 | rep, km, llaves | sin salida ⚠2 fotos | — | 2 |
| KON305 | 2026-07-22 | 8/12 | motor, baul, rep, llaves | sin salida ⚠3 fotos | — | 2 |
| GZJ4876 | 2026-07-22 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| BYK082 | 2026-07-22 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LKT543 | 2026-07-22 | 11/12 | int3 | sin salida ⚠3 fotos | — | 0 |
| JUS946 | 2026-07-22 | 2/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, llaves | 7/12 | lat.der, motor, int3, rep, llaves | 0 |
| FUW034 | 2026-07-22 | 3/12 | lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | int2, int3, llaves | 5 |
| NCQ540 | 2026-07-23 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| KUQ084 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| FRS438 | 2026-07-23 | 9/12 | int3, rep, llaves | sin salida ⚠4 fotos | — | 4 |
| FWW805 | 2026-07-23 | 10/12 | baul, llaves | sin salida ⚠2 fotos | — | 1 |
| KMV678 | 2026-07-23 | 2/12 | lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida ⚠3 fotos | — | 6 |
| PUX938 | 2026-07-23 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| LMX240 | 2026-07-23 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| HEX561 | 2026-07-23 | 10/12 | baul, llaves | sin salida ⚠1 fotos | — | 0 |
| LNX629 | 2026-07-23 | 3/12 | del, lat.der, lat.izq, int1, int2, int3, baul, rep, llaves | 11/12 | baul | 0 |
| KCM752 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| IJX407 | 2026-07-23 | 10/12 | int3, rep | sin salida ⚠3 fotos | — | 3 |
| GZT041 | 2026-07-23 | 2/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, km, llaves | 9/12 | int3, rep, llaves | 0 |
| IJS257 | 2026-07-23 | 11/12 | rep | 2/12 | del, post, lat.der, lat.izq, int1, int2, int3, rep, km, llaves | 0 |
| JRU450 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| PAU345 | 2026-07-23 | 8/12 | int2, int3, baul, llaves | sin salida ⚠3 fotos | — | 5 |
| LUQ477 | 2026-07-23 | 10/12 | rep, km | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 3 |
| DGU200 | 2026-07-23 | 6/12 | motor, int3, baul, rep, km, llaves | sin salida ⚠3 fotos | — | 1 |
| LZQ834 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| LSN099 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LGW080 | 2026-07-23 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LJV023 | 2026-07-23 | 9/12 | int3, baul, km | sin salida ⚠2 fotos | — | 4 |
| TTM940 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| LUW404 | 2026-07-23 | 1/12 | del, post, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | int3, baul, rep | 0 |
| LRU574 | 2026-07-23 | 9/12 | int3, rep, km | sin salida ⚠1 fotos | — | 0 |
| LLM590 | 2026-07-23 | 10/12 | lat.izq, llaves | sin salida | — | 2 |
| QGV949 | 2026-07-23 | 1/12 | del, post, lat.der, lat.izq, motor, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| LGZ432 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 1 |
| HPV793 | 2026-07-23 | 11/12 | baul | sin salida ⚠3 fotos | — | 1 |
| FSQ328 | 2026-07-23 | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 1/12 | del, post, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| JOM000 | 2026-07-23 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| RMN254 | 2026-07-23 | 9/12 | int3, baul, km | 3/12 | del, lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 0 |
| KTK432 | 2026-07-23 | 10/12 | int2, int3 | sin salida ⚠3 fotos | — | 5 |
| ZYS636 | 2026-07-23 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | motor, llaves | 3 |
| FNS630 | 2026-07-23 | 3/12 | lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 9/12 | int3, baul, llaves | 1 |
| FGQ090 | 2026-07-23 | 9/12 | int3, rep, llaves | sin salida | — | 6 |
| URT033 | 2026-07-23 | 2/12 | del, lat.der, lat.izq, int1, int2, int3, baul, rep, km, llaves | 10/12 | int3, rep | 1 |
| MUM864 | 2026-07-23 | 4/12 | lat.der, lat.izq, int1, int2, int3, rep, km, llaves | 10/12 | rep, llaves | 3 |
| POY728 | 2026-07-23 | 11/12 | int3 | 2/12 | del, post, lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 2 |
| HJN610 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 11/12 | int3 | 1 |
| NSV848 | 2026-07-23 | 3/12 | lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 2 |
| VCV359 | 2026-07-23 | 8/12 | baul, rep, km, llaves | sin salida | — | 7 |
| LSO963 | 2026-07-23 | 12/12 | — | 2/12 | del, post, lat.der, lat.izq, int1, int2, int3, rep, km, llaves | 1 |
| DSK912 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 10/12 | int3, km | 0 |
| KSM988 | 2026-07-23 | 3/12 | del, post, lat.der, lat.izq, motor, int3, rep, km, llaves | 9/12 | del, rep, llaves | 0 |
| NBL716 | 2026-07-23 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| UGL635 | 2026-07-23 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| EGX423 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 4/12 | motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| NIT892 | 2026-07-23 | 9/12 | int2, int3, baul | sin salida | — | 6 |
| NSU645 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| NPT763 | 2026-07-23 | 10/12 | km, llaves | 5/12 | lat.izq, int1, int2, int3, rep, km, llaves | 1 |
| WGM704 | 2026-07-23 | 4/12 | lat.der, lat.izq, int2, int3, baul, rep, km, llaves | 10/12 | km, llaves | 6 |
| NHM516 | 2026-07-23 | 11/12 | llaves | 3/12 | post, lat.der, lat.izq, motor, int2, int3, rep, km, llaves | 1 |
| NHO296 | 2026-07-23 | 11/12 | km | sin salida | — | 0 |
| FXU833 | 2026-07-23 | 5/12 | lat.der, lat.izq, motor, int3, baul, rep, llaves | 7/12 | lat.izq, int1, int2, int3, llaves | 2 |
| EGX788 | 2026-07-23 | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0/12 | del, post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | 0 |
| FOV607 | 2026-07-23 | 1/12 | post, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |
| IXP535 | 2026-07-23 | 1/12 | del, lat.der, lat.izq, motor, int1, int2, int3, baul, rep, km, llaves | sin salida | — | 0 |

## Fichas con fotos de "salida" sin salida anunciada (revisar)

Estas fotos de salida las metieron los barridos anteriores (antes del blindaje de hoy):
duplicados del ingreso que se desbordaron a cajones de salida. Recomendado revisarlas en
el hub y quitarlas si el carro no ha salido.

FSW622, EPP666, MXR019, KQM195, IUY843, KNV490, IUS310, LXV611, KTV634, FKO152, LTO840, GKU696,
LLM818, PMW754, GKU887, KSM613, EBT059, LGV334, LZR992, NWN494, DAX214, NPY363, NFN791, XWD385,
JTV551, GPS787, KYT458, JNL898, FZO734, KPN431, EJY840, FSY420, KPR465, GFK476, NQO372, MVM881,
LJK11D, FUU796, HET528, KQL443, RBZ932, IUT416, KVQ278, JLN651, HRQ422, NOR476, JDY584, EOL622,
LKP464, UEL177, GEP266, GEL528, IYN563, YZX51F, BWF233, HBT703, TZQ061, EGO804, CRK768, MVN253,
KWF63H, CKJ008, KWS933, JGL001, EBR098, GFO127, FZQ313, PGM064, MPT209, GRM108, DRL884, WLV855,
WLU855, TGY097, KQW138, LYR688, JRW312, EPQ970, HSL834, JPP789, LCP808, HDW651, JYU593, LYQ192,
KCG16F, ENU185, LGL905, LZZ161, PMW492, KQN829, LIU651, TJP299, TRI914, JHT002, MVZ343, DZI115,
WDE591, KXL978, WMK567, EFP539, EPC27H, KVW883, WNL14F, JYY844, MVM073, EJR730, LFZ129, GSZ418,
KRX790, LGP488, NPP315, HYR884, ENO180, NDU670, DRZ910, LXV835, JSO360, KYY444, LQS322, HQK553,
BWB168, OEX63E, IXO871, RZW678, KOK213, MCL871, HTY114, CWF050, FSK717, KMW739, QWP68G, UWQ769,
KUY253, LFX748, NGU85A, NFU21G, UEL208, TZO597, KWT505, UUN410, NIK396, VEZ572, HWE30G, NQO205,
GWM905, DOR565, AXL566, LKR527, NTY012, NTR268, NLS494, KQX654, UIA087, BIR29D, JUP427, NGX066,
LRM515, SQM151, JQS824, IVS956, GHL199, KON305, LKT543, FRS438, FWW805, KMV678, HEX561, IJX407,
PAU345, DGU200, LJV023, LRU574, HPV793, KTK432,

## Qué se hizo hoy

- Se blindó `retomar_fotos_vehiculos`: ya no llena cajones de "salida" si el carro no
  tiene salida registrada ni anuncio de SALE en el chat, y no gasta visión en fichas completas.
- Recuperación global aplicada: **29 fotos** adjuntadas en 17 fichas (además de las 19+3 del arranque).
- **KSV486** corregida: se quitaron 2 fotos falsas de salida, y el "posterior" del ingreso
  (foto del carro montado en la grúa) se reemplazó por la trasera real del patio.
  Sus 7 faltantes (motor, int2, int3, baúl, repuesto, km, llaves) se perdieron en la caída
  de la línea del 14-jul 9:32–9:49 am: el celular puente sí las tiene; hay que reenviarlas
  con caption `*KSV486*`.
