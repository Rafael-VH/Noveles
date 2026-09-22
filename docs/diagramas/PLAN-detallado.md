# Plan detallado de diagramas interactivos — Noveles

> Generado con **ArchMan** → `archify-suite` (set canónico) + `archify-drift` (frescura),
> reestructurado **por fases** para implementación gradual con revisión entre fases.
> Fecha: 2026-09-22 · HEAD: `98cde59`

---

## Cómo leer este plan

Cada fase es una unidad de implementación con su propio **objetivo**, **entregable**,
**brief de autoría** y **criterios de aceptación**. Al terminar una fase se revisa el
diagrama interactivo en el dashboard **antes** de arrancar la siguiente (gate de
revisión). Las fases tienen dependencias ordenadas: no saltear la 0.

**Mapa de fases**

| Fase | Nombre | Entregable | Tipo | ¿Diagrama nuevo? |
|---|---|---|---|---|
| 0 | Fundamentos y evidencia | specs existentes con `revision` + `sources` | — | No |
| 1 | Ingesta de contenido | `pipeline` | `workflow` | Sí |
| 2 | Autenticación y ruteo | `secuencia-clave` | `sequence` | Sí |
| 3 | Ciclo de vida de roles | `ciclo-de-vida` | `lifecycle` | Sí |
| 4 | Interacción por rol | `roles-interaccion` | `workflow` (swimlanes) | Sí |
| 5 | Cierre y mantenimiento | dashboard + CI + guardia | — | No |

**Estado actual de referencia**: 1 de 5 del set canónico (arquitectura ✅ en 2 diagramas
existentes); ambos diagramas actuales **sin evidencia** en drift (specs sin `revision` ni
`components[].sources[].path`). `datos` (dataflow): **descartado** — app CRUD sin ETL
(pendiente solo si AnalyticsTab crece a reportes reales).

---

## Fase 0 — Fundamentos y evidencia

**Objetivo**: que los 2 diagramas existentes sean auditables por `archify-drift` antes de
agregar más. Sin esto, la frescura futura es "sin evidencia".

**Deliverables**:

- `architecture/architecture.json` con `meta.repository.revision` (HEAD) y
  `components[].sources[].path` por nodo.
- `supabase/supabase.json` idem.
- HTML re-entregados con `archify deliver` (9/9 checks) y misma geometría/presets.
- `diagrams_guard_test.dart` en verde.

**Pasos**:

1. Relevar rutas reales por nodo (grep archivos que definen cada nodo).
2. Editar ambas specs: `revision` + `sources`.
3. `archify validate` → 0 errores, 0 warnings.
4. `archify deliver` → 9/9 artifact checks, `viewBox` contiene 1440×900/1600×1000/1920×1080,
   link "Volver al dashboard" antes de `</body>`.
5. Correr `drift.mjs` → los 2 deben salir `al día`.

**Definición de hecho**: drift reporta 2 `al día` (no `sin evidencia`).

**Riesgo**: bajo. Es metadata, no rediseño.

---

## Fase 1 — Ingesta de contenido (pipeline)

**Objetivo**: mostrar la transformación central de punta a punta: un archivo que entra por
el panel scan y termina como contenido legible.

**Deliverable**: `docs/diagramas/pipeline/` (spec + HTML).

**Brief** (caso concreto):

```
Archivo .md/.txt (scan)
  → ScanChapterEditScreen · UploadChapterFile
  → ChapterRepository.uploadContent()
  → Storage bucket `chapters` (filename {timestamp}.{ext})
  → URL pública → campo content del capítulo
  → INSERT chapters (RLS: is_scan())
  → lector: GetChapterContent → MainScreen
```

| Checklist (archify-suite) | Cómo se cumple |
|---|---|
| Un solo camino principal I→D | Archivo → Storage → DB → lector, horizontal |
| Ramas laterales del nodo más cercano | Rama de cover (`covers` bucket) sale del nodo de ingestión |
| Etiquetas de acción en aristas | "sube", "guarda URL", "INSERT", "fetch" — no repetir nombres |
| Puntos de fallo/reintento | Variante diferenciada: fallo de upload / timeout 10s del Completer |

**`sources` candidatos**: `lib/features/chapters/data/chapter_repository_impl.dart`,
`lib/features/scan/presentation/screens/scan_chapter_edit_screen.dart`,
`lib/core/constants/storage_constants.dart`.

**Pasos**: relevar fuentes → redactar spec → `validate` → `deliver` → regenerar dashboard →
`drift`.

**Definición de hecho**: card `pipeline` visible en el dashboard y diagrama interactivo
revisado.

**Gate de revisión**: confirmar el flujo con los screens de scan antes de seguir.

**Riesgo**: bajo-medio; el flujo ya está documentado en `docs/es/features/scan/README.md`.

---

## Fase 2 — Autenticación y ruteo (secuencia-clave)

**Objetivo**: el caso más importante del sistema — login encadenado a través de los tres
gateways y el ruteo por rol.

**Deliverable**: `docs/diagramas/secuencia-clave/` (spec + HTML).

**Brief**:

```
Caso: "Login y selección de pantalla por rol"
Participantes: LoginScreen · AuthBloc · Login/GetCurrentUser · AuthRepository ·
               AuthGateway + DataGateway · Supabase Auth · profiles · App (router)
Segmentos: (1) credenciales → sesión, (2) carga/creación de profiles,
           (3) routing: isAdmin → AdminDash / isScan → ScanMain / else → Main
Retornos: Result<UserEntity> Ok/Err; eventos AuthAuthenticated / AuthError /
          AuthUnauthenticated (incl. logout por expiración de token vía stream)
```

| Checklist | Cómo se cumple |
|---|---|
| Participantes semánticos | Pantalla, BLoC, repositorio, gateways, backend — no clases Dart |
| Ida y vuelta marcada | Retornos con variante (Ok/Err, stream de auth) |
| Segmentos por fases | 3 fases claras: auth → profile → routing |
| Caso concreto nombrado | "Login y ruteo por rol", no "flujo general" |

**`sources` candidatos**: `lib/features/auth/presentation/bloc/auth_bloc.dart`,
`lib/features/auth/data/auth_repository_impl.dart`, `lib/core/app/app.dart`,
`lib/bootstrap/injection.dart`.

**Definición de hecho**: card `secuencia-clave` en el dashboard, revisada contra
`docs/es/features/auth/README.md`.

**Gate de revisión**: confirmar el segmento de routing (es el que define qué ve cada rol).

**Riesgo**: bajo — hay Mermaid de referencia en `docs/es/user-types/scan-user.md §2`.

---

## Fase 3 — Ciclo de vida de roles (ciclo-de-vida)

**Objetivo**: los estados que atraviesa un usuario y cómo sale de cada uno.

**Deliverable**: `docs/diagramas/ciclo-de-vida/` (spec + HTML).

**Brief**:

```
Estados (enum + CHECK): user · scan · admin · suspended
Inicial: trigger de registro crea profiles con role = 'user'
Transiciones:
  user → scan      (admin promueve, UpdateUserRole)
  user → admin     (admin promueve)
  user ↔ suspended (admin suspende/reactiva; suspendido NO puede loguearse:
                    routing cae en LoginScreen)
Terminales: ninguno permanente — suspended es recuperable
```

| Checklist | Cómo se cumple |
|---|---|
| Estados del dominio | `user`, `scan`, `admin`, `suspended` — no "estado 2" |
| Finales vs esperas | `suspended` marcado como recuperable, no terminal |
| Fallo recuperable con transición real | suspended → user vía `AdminUsersBloc._onSuspendUser()` |
| Inicial y terminales marcados | inicial = `user` (trigger); sin terminal fijo |

**`sources` candidatos**: `lib/features/profiles/domain/user_role.dart`,
`lib/features/admin/presentation/bloc/admin_users_bloc.dart`, `lib/core/app/app.dart`,
migración `20260720040000_add_suspended_role.sql`.

**Definición de hecho**: card `ciclo-de-vida` en el dashboard, revisada contra
`docs/es/user-types/*.md`.

**Gate de revisión**: validar la transición suspended → user (reactivación).

**Riesgo**: muy bajo — enum estable, bien documentado.

---

## Fase 4 — Interacción por rol (roles-interaccion) — ficha custom

**Objetivo**: el contraste que los documentos no dan: qué ve y qué hace cada rol sobre la
misma plataforma, con permisos RLS diferenciados.

**Deliverable**: `docs/diagramas/roles-interaccion/` (spec + HTML).

**Forma**: `workflow` de tres calles (swimlanes), una por rol, en orden de privilegio:

```
lane user   → LoginScreen → MainScreen: libro (solo is_visible=true) → leer capítulo
             → favoritos · recientes · marcar leído · editar perfil
lane scan   → LoginScreen → ScanMainScreen: CRUD libro (propios, created_by=auth.uid())
             → tooks → capítulos → upload .md/.txt (bucket chapters) · covers · etiquetas
lane admin  → LoginScreen → AdminDash: gestión de usuarios (roles · suspender)
             → géneros · etiquetas · analytics (book_views) · contenido completo
```

Las tres calles terminan en los **mismos subsistemas** (Auth, Storage, DB) con la
**condición RLS etiquetada en cada flecha**: `is_visible = true` (user),
`created_by = auth.uid()` (scan), `is_admin()` (admin). Nodo diferenciado para `suspended`
(cae en LoginScreen).

| Checklist (adaptado) | Cómo se cumple |
|---|---|
| Un camino principal por lane | Una calle por rol, de login a su pantalla y acciones |
| Ramas laterales del nodo más cercano | Acciones secundarias (perfil, favoritos) salen del nodo de pantalla |
| Etiquetas de acción concretas | "lee visibles", "CRUD propios", "gestiona roles" |
| Fallos/perímetros | `suspended` → LoginScreen (sin acceso) |
| Contraste de permisos | Aristas a DB/Storage etiquetadas con su condición RLS |

**`sources` candidatos**: `lib/core/app/app.dart`, `lib/features/profiles/domain/user_role.dart`,
`docs/es/user-types/` (regular/scan/admin/suspended), migraciones RLS de `supabase/migrations/`.

**Nota**: ficha custom fuera del set canónico. No duplica a `ciclo-de-vida`: ese responde
"qué estados atraviesa un rol"; este responde "qué interacción permite cada estado".

**Definición de hecho**: card `roles-interaccion` en el dashboard; contraste RLS visible
por lane.

**Gate de revisión**: el contraste de permisos entre las 3 calles es el criterio — si no se
ve de una mirada, rehacer.

**Riesgo**: medio (3 lanes en una sola vista; cuidar el presupuesto de geometría).

---

## Fase 5 — Cierre y mantenimiento

**Objetivo**: dejar la galería completa, auditada y protegida contra el silencio.

**Pasos**:

1. Regenerar dashboard final (`tools/build-diagrams.mjs`) → 6 cards (architecture,
   supabase, pipeline, secuencia-clave, ciclo-de-vida, roles-interaccion).
2. `drift.mjs --estricto` en CI (workflow `diagramas.yml`) — bloquea solo `roto`;
   `a revisar` informa sin romper.
3. Verificar `diagrams_guard_test.dart` en verde y ampliar su lista curada si alguna ficha
   agregó strings sensibles (p. ej. "constraint", condiciones RLS).
4. Committear specs JSON junto a los HTML (fuente reproducible) y actualizar `manifest.json`.

**Definición de hecho**: galería completa en GitHub Pages, drift en verde, guardia en verde,
specs con evidencia.

**Riesgo**: bajo.

---

## Criterios de aceptación comunes (toda entrega archify)

- `archify validate` → 0 errores, 0 warnings
- `archify deliver` → 9/9 artifact checks
- `viewBox` contiene 1440×900 / 1600×1000 / 1920×1080
- Link "Volver al dashboard" antes de `</body>`
- Atributos `data-*` de nodos/aristas presentes (API del runtime)
- Spec JSON commiteada junto al HTML
- `diagrams_guard_test.dart` en verde
- Dashboard regenerado y card visible

---

## Resultado esperado al cerrar las 5 fases

**5 diagramas interactivos entregados** (4 canónicos + 1 ficha custom), **6 cards** en el
dashboard, 2 diagramas preexistentes auditables por drift, `datos` descartado con
justificación documentada, y CI protegiendo la frescura.

*Plan de la skill `archify-suite` (catálogo canónico) + `archify-drift` (frescura), curado
con el contexto del repo y reestructurado por fases. La autoría de cada diagrama es de
`/archify` vía ArchMan; este documento define el estándar, el orden y los gates de
revisión.*