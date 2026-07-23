# Storage

> 3 buckets: avatars, covers, chapters.
> Todos los buckets tienen acceso de lectura público.

## Buckets

### avatars

| Propiedad | Valor |
| --------- | ----- |
| Público | ✅ Sí |
| Límite de Tamaño | Ninguno |
| Tipos MIME Permitidos | Cualquiera |

**Propósito**: Fotos de perfil de usuario.
**Estructura de Carpetas**: `{user_id}/{filename}`

---

### covers

| Propiedad | Valor |
| --------- | ----- |
| Público | ✅ Sí |
| Límite de Tamaño | 50 MB |
| Tipos MIME Permitidos | image/png, image/jpeg, image/webp |

**Propósito**: Imágenes de portada de libros.
**Estructura de Carpetas**: `{user_id}/{timestamp}.{ext}`

---

### chapters

| Propiedad | Valor |
| --------- | ----- |
| Público | ✅ Sí |
| Límite de Tamaño | 10 MB |
| Tipos MIME Permitidos | text/plain |

**Propósito**: Archivos de contenido de capítulos.
**Estructura de Carpetas**: `{user_id}/{timestamp}.{ext}`

---

## Políticas RLS

### Bucket covers

| Operación | Nombre de Política | Condición |
| --------- | ------------------ | --------- |
| INSERT | Insert autenticado en carpeta propia | bucket_id = 'covers' A... |
| UPDATE | Update autenticado en carpeta propia | Igual que INSERT |
| DELETE | Delete autenticado en carpeta propia | Igual que INSERT |

### Bucket chapters

| Operación | Nombre de Política | Condición |
| --------- | ------------------ | --------- |
| INSERT | Insert autenticado en carpeta propia | bucket_id = 'chapter... |
| UPDATE | Update autenticado en carpeta propia | Igual que INSERT |
| DELETE | Delete autenticado en carpeta propia | Igual que INSERT |

---

## Estructura de Carpetas

```text
covers/
  {user_id}/
    {timestamp}.jpg
    {timestamp}.png

chapters/
  {user_id}/
    {timestamp}.txt

avatars/
  {user_id}/
    {filename}
```text

**Puntos Clave**:

- Todas las subidas tienen el prefijo `{user_id}/` — los usuarios solo pueden
  acceder a su propia carpeta
- Los archivos existentes en la raíz (sin prefijo de usuario) aún son legibles
  pero no se pueden modificar
- Las nuevas subidas siempre van a carpetas específicas del usuario

---

## Notas de Seguridad

### ✅ Seguro

- Subida restringida a usuarios autenticados
- Los usuarios solo pueden subir a su propia carpeta (`{user_id}/`)
- Los usuarios solo pueden eliminar sus propios archivos
- Validación de tipo MIME en covers (solo imágenes) y chapters (solo texto)
- Límites de tamaño de archivo aplicados

### ⚠️ Monitorear

- Los buckets son públicos — cualquiera con la URL puede leer archivos
- Sin límite de tasa en subidas
- Sin análisis de virus en archivos subidos
