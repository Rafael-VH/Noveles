# Plan — Corregir el diagrama de arquitectura tras el desacople de Supabase

> Estado: **implementado (2026-09-21)** vía opción B+C — ver la sección 9.
> Origen: auditoría posterior a los commits `9996c51`, `397378f`, `7b08cc9` y `9dfe32e`.

## 1. Veredicto de la auditoría

| Artefacto | ¿Afectado? | Evidencia |
|---|---|---|
| `overview/architecture.svg` (28.369 B) | **Sí** | Nodo `data` con subtítulo `Repos + Models · Supabase client` (líneas 111 y 119) |
| `overview/architecture.html` (818.582 B) | **Sí** | Mismo diagrama: `archify-diagram-title` aparece 2× en ambos archivos; el texto del SVG está embebido y es buscable (`Repos + Models` aparece 4×) |
| `README.md` línea 69 | **Sí, expuesto** | Muestra ese SVG inline en la portada del repo |
| `backend/supabase.svg` + `.html` | **No** | Cero coincidencias de `supabase client`, `provider`, `repository`, `dart` o `flutter` |
| `diagrams/index.html` | **No** | Genérico: se arma leyendo `manifest.json` |
| `manifest.json` | **Parcialmente** | La entrada `architecture` dice `Clean Architecture · Flutter + Supabase`, sin mencionar la costura |

### Por qué `backend/supabase.*` NO se toca

Se deja constancia explícita para que nadie gaste trabajo ni riesgo ahí: el esquema, las políticas
RLS, auth, buckets y Edge Functions no cambiaron en estos commits, y las 18 migraciones renombradas
son renames al 100% con contenido byte-idéntico. Además el `"13 tablas"` de su descripción en el
manifest coincide con exactamente **13** sentencias `CREATE TABLE` en `supabase/migrations`.

## 2. Delta exacto del diagrama de arquitectura

Inventario del archivo: **11 nodos**, **9 aristas etiquetadas**, **2 sin etiqueta**, **4 zonas**,
`viewBox="0 0 1540 700"`.

### Nodo afectado

| Elemento | Hoy | Debería expresar |
|---|---|---|
| `g id="node-data"` → subtítulo | `Repos + Models · Supabase client` | `Repos + Models · Ports` |

La capa `Data` dejó de conocer el vendor: hoy depende de tres interfaces.

### Nodos faltantes

El refactor introdujo una capa que el diagrama no dibuja:

- **Ports** — `DataGateway` / `AuthGateway` / `StorageGateway`, la frontera que `Data` conoce.
- **Adapters** — `lib/core/backend/supabase/`, el único lugar donde vive el SDK de Supabase.

Sin ellos, el diagrama sigue mostrando el acople directo que este trabajo eliminó.

### Aristas mal ancladas

| Arista | Etiqueta | Problema |
|---|---|---|
| `data → pg` | `PostgREST · SQL` | Ya no nace en `data`: nace en el adaptador |
| `data → storage` | `sube / baja` | Ídem |
| `di → data` | `registra impls` | Ahora también registra el módulo de backend y llama a `initializeBackend()` |

### Verificado como correcto (no tocar)

Aristas: `readers→presentation` ("interactúa"), `presentation→domain` ("bloc → use case"),
`admin→domain` y `scan→domain` (sin etiqueta), `domain→data` ("contratos → impls"),
`cache→data` ("prefs locales"), `sbauth→pg` ("RLS · roles"), `edge→pg` ("service role · sync").

Nodos: `presentation`, `admin`, `scan`, `domain`, `cache`, `di`, `sbauth`, `pg`, `storage`, `edge`.

### Decisión abierta de taxonomía

Los `data-node-kind` existentes son `frontend`, `backend`, `database`, `cloud` y `security`. No hay
un kind para ports ni adapters. Hay que decidir cuál usar para los nodos nuevos (probablemente
`backend`, igual que `domain`, que es `kind="backend"`).

## 3. Deriva preexistente (no causada por el desacople)

Se documenta para decidirla en la misma pasada, marcada como *preexistente*:

- `Blocs + Screens · 13 features` frente a **10** carpetas reales en `lib/features`. No se pudo
  reproducir de dónde sale el 13.
- **Storage contradictorio**: arquitectura dice `covers · chapters`, el diagrama de backend dice
  `covers · avatars`, y `storage_constants.dart` define **tres** buckets: `covers`, `chapters` y
  `avatars`. Los dos diagramas están incompletos.
- La guía lista carpetas `client/` y `workflows/` que no existen: son placeholders del manifest.

## 4. Restricción de fondo: no hay fuente reproducible

El generador es una herramienta externa —`archify 2.17.0-dev.1`, con `data-preset="classic"`,
`data-quality-profile="standard"` y `lang="es"`— y el repo solo contiene los outputs. No hay spec,
ni config, ni script: las 30 coincidencias de `archify`/`ArchMan` en el proyecto están todas dentro
de los archivos generados, la guía o el manifest.

Consecuencia: no se puede "volver a generar lo mismo". Cualquier regeneración produce un layout
nuevo, y cualquier parche a mano obliga a recalcular geometría.

## 5. Opciones

- **A — Regenerar con archify.** Es lo que manda la guía. Permite además corregir la deriva
  preexistente de una sola vez. Contra: requiere la herramienta y el layout no queda idéntico
  (posiciones, radios y `viewBox` se recalculan).
- **B — Parchear a mano los dos archivos.** No requiere herramienta y es técnicamente viable,
  porque el SVG es autodescriptivo (`data-node-id`, `data-node-kind`, `data-node-sublabel`,
  `data-edge-from/to/label`, `data-composition-points`) y el runtime es DOM-driven. Contra: hay que
  recalcular las coordenadas de los nodos y las curvas `Q` de los conectores, y replicar el parche
  idéntico en tres lugares: el `.svg`, el SVG embebido del `.html` y lo que renderiza el README.
- **C — Interino.** Corregir solo lo editable a mano (la descripción en `manifest.json` y una nota
  en el README) y agendar la regeneración.

**Recomendación: A, con C como paso interino**, más commitear la spec de entrada —o al menos
registrar la versión de la herramienta y la descripción usada— para que el diagrama deje de ser
irreproducible.

## 6. Pasos de ejecución (cuando se apruebe implementar)

1. Fijar el modelo objetivo: los dos nodos nuevos, sus `kind`, y las tres aristas reancladas.
2. Regenerar con archify manteniendo preset, quality profile y `lang="es"`.
3. Reubicar el par en `docs/diagrams/overview/` sin cambiar nombre ni ruta.
4. Verificar que el link de vuelta al dashboard siga antes de `</body>`: es la regla obligatoria de
   la guía y lo primero que se pierde al regenerar.
5. Actualizar la descripción de la entrada `architecture` en `manifest.json`.
6. Commitear la spec de entrada junto a los outputs.

## 7. Verificación

- `manifest.json` sigue siendo JSON válido y su campo `file` apunta a un archivo existente.
- El SVG regenerado conserva el link de vuelta y mantiene los atributos `data-*` de nodos y aristas,
  que son la API del runtime DOM-driven.
- Cero coincidencias de `Repos + Models · Supabase client` en `docs/diagrams/**`.
- El dashboard online carga la card y el interactivo. GitHub Pages tarda ~1-2 min tras el push.

## 8. Hardening opcional: que no vuelva a pasar en silencio

Agregar una guardia barata a la suite que grepee `docs/diagrams/**` buscando identificadores
prohibidos (`SupabaseClientProvider`, `lib/core/supabase`) y afirmaciones de capa ya falsas, con una
lista curada y mantenida a mano.

Límite honesto: el diagrama nombra **capas**, no rutas de código, así que la guardia solo cubre lo
que se enumere explícitamente. No es una garantía de exactitud, pero habría atrapado este caso.

## 9. Implementación (2026-09-21)

Se ejecutó la **opción B** (parche manual del SVG y del SVG embebido en el HTML) más la **opción C**
(manifest), porque la A requiere archify y no está disponible. Decisiones tomadas:

- **Nodos agregados**: `ports` (DataGateway · AuthGateway · StorageGateway, junto a Data, dentro del
  frame del cliente) y `adapters` (`core/backend/supabase/ · único lugar con el SDK`, en el corredor
  entre frames, con `data-node-context` del backend: físicamente pertenece al repo pero lógicamente
  al lado del vendor).
- **Aristas reancladas**: `data→ports` ("usa"), `ports→adapters` ("implementan"), y desde adapters
  salen `PostgREST · SQL` a pg, `API de Storage` a storage y `GoTrue` a sbauth. `di→data` conserva
  su etiqueta ("registra impls") porque sigue siendo cierta.
- **Deriva corregida en la misma pasada**: `13 features` → `10` (SVG, HTML y card del lector),
  buckets completos `covers · chapters · avatars` en los dos diagramas y en el manifest,
  `PostgreSQL` ahora dice `13 tablas · RPC · RLS`, y `Supabase Auth` bajó de y=110 a y=190 para
  dejar paso al conector GoTrue sin cruzar la Auth Trust Zone.
- **Guardia implementada**: `test/architecture/diagrams_guard_test.dart` — escanea los `.html`/
  `.svg` de `docs/diagrams/`, falla con `Repos + Models · Supabase client`, `SupabaseClientProvider`
  o `lib/core/supabase`, y valida que cada "N features" declarado coincida con `lib/features`.
- **Preservado**: `viewBox` 1540×700, presets, el link "Volver al dashboard" antes de `</body>` y
  los atributos `data-*` que consume el runtime.
- **Queda abierto**: regenerar con archify cuando esté disponible (los layouts hechos a mano no
  reemplazan una fuente), y sumar más casos a las listas de la guardia a medida que aparezcan.

## 10. Cierre (2026-09-21): la opción A sí era posible y se ejecutó

El punto "Queda abierto" quedó cerrado: archify **sí estaba disponible**
(`~/.agents/skills/archify/bin/archify.mjs`) — la conclusión inversa de la auditoría fue un error
de búsqueda, no un dato del entorno. Consecuencias:

- **La fuente ya no son los HTML**: se autoraron las especificaciones
  `architecture/architecture.json` y `supabase/supabase.json` a partir del inventario exacto de los
  diagramas parcheados (nodos, kinds, posiciones y aristas extraídos programáticamente), se
  validaron con `archify validate` hasta cero errores y se regeneraron con `archify deliver`
  (9/9 artifact checks en ambos). El parche manual queda en este documento como historia.
- **Casa nueva**: `docs/diagramas/<slug>/` según la skill `archify-diagrams-dashboard`, con
  `tools/build-diagrams.mjs`, workflow de frescura en CI y publicación en GitHub Pages. La carpeta
  `docs/diagrams/` (dashboard artesanal) fue eliminada.
- **Guardia reorientada**: `diagrams_guard_test.dart` ahora escanea `docs/diagramas/` (incluye los
  HTML archify, que llevan la spec embebida).
- **Nota de contenido**: en el diagrama de backend, las cajas decorativas del SVG viejo se
  reemplazaron por un boundary `security-group` "RLS everywhere" y dos conexiones decorativas sin
  flujo real (Signed URL, auto-etiquetado) se movieron a sublabels/cards: archify rechaza aristas
  que cruzan nodos o siguen bordes de zonas.
