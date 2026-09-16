# Agregar / actualizar diagramas en GitHub Pages

> Ruta final del dashboard online: **https://rafael-vh.github.io/Noveles/diagrams/**
> Fuente: rama **main**, carpeta **/docs** (GitHub Pages -> Source: Deploy from a branch, /docs).

## Cómo funciona — estructura

Cada diagrama vive en una **carpeta por dominio** dentro de `docs/diagrams/`:

```
docs/diagrams/
  index.html                # Dashboard: se arma solo leyendo manifest.json (no lo toques)
  manifest.json             # ÚNICO archivo que editás al agregar/actualizar un diagrama
  overview/                 # Visión general del sistema (ej. architecture.*)
  backend/                  # Backend: Supabase / Auth / Storage / Edge Functions
  client/                   # Cliente: Flutter / BLoC / temas / routing
  workflows/                # Flujos: registro, lectura, etiquetas automáticas, moderación
```

Dos tipos de archivo por diagrama:
- **`<nombre>.svg`** — el diagrama en sí (lo ve el navegador de GitHub directo, sin Pages).
- **`<nombre>.html`** — versión interactiva (pan/zoom, temas, búsqueda, export). **Sí lo sirve GitHub Pages**.

Se generan con **ArchMan/archify**; después se reorganizan a la carpeta de su dominio (arriba).

## Agregar un diagrama nuevo (3 pasos)

1. **Generalo** con ArchMan/archify → tomá como `<nombre>.html` y `<nombre>.svg`.
2. **Movelo a su dominio**: `git mv docs/diagrams/<nombre>.html docs/diagrams/<dominio>/<nombre>.html` (igual el `.svg`).
3. **Registralo en `manifest.json`**: dentro de `groups[].diagrams[]` del grupo que corresponde:

```json
{ "id": "nombre", "name": "Nombre", "description": "Una línea", "file": "<dominio>/<nombre>.html", "tag": "core" }
```

El dashboard lo detecta solo: no hay que tocar `index.html`.

## Actualizar un diagrama existente

1. Regenerá el `.html`/`.svg` con ArchMan (misma ruta).
2. Subí los cambios: `git add docs/diagrams && git commit -m "docs(diagrams): actualiza <nombre>" && git push`

GitHub Pages **rebuilda solo** con cada push a main. El deploy tarda ~1-2 min.

## Checklist antes de pushear

- [ ] `manifest.json` es JSON válido (se refleja en el dashboard).
- [ ] `file` apunta a `<dominio>/<nombre>.html` y ese archivo existe y está commiteado.
- [ ] Después del push, abrí la URL online y verificá la card + el interactivo.