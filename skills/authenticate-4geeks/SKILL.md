# authenticate-4geeks

## Description
Autenticación y consulta de datos vía API de 4Geeks Academy (BreatheCode).
Usa el token de estudiante almacenado en `TOKEN_4GEEKS` para operar sobre tareas,
perfil, cohortes, actividad, entregas, certificados y catálogo.

## Origen
Creada a partir de la documentación oficial:
https://github.com/4GeeksAcademy/ai-engineering-syllabus/blob/main/content/projects/openclaw-integration/STUDENT_API_CALLS_REFERENCE.es.md
Conversación original registrada en `SKILL_LOG.md`.

## Configuración requerida

Variables de entorno (ya definidas en el host):
- `TOKEN_4GEEKS` — Token de acceso personal de 4Geeks
- `API_4GEEKS_TODO` — (opcional) URL del Playground TODO

La skill se activa vía `openclaw.json` en `skills.entries.authenticate-4geeks`.

## Uso general

Base URL (producción): `https://breathecode.herokuapp.com`
Auth header: `Authorization: Token $TOKEN_4GEEKS`

Siempre ejecutar los endpoints contra la base URL de producción.
Usar `curl -sL` con el header de auth correspondiente.

## Comandos / herramientas que puedo ejecutar

### 1. Tareas por estado (task_status) — Skill 1: Autenticar

Endpoints relacionados: `GET /v1/assignment/user/me/task`

Filtro vía query param `task_status` con los valores:

| Valor     | Descripción                                  |
|-----------|----------------------------------------------|
| PENDING   | Pendiente — no entregada                     |
| DONE      | Completada por el estudiante                 |
| APPROVED  | Aprobada en revisión                         |
| REJECTED  | Rechazada — requiere correcciones            |

También admite filtros adicionales:
- `task_type` — PROJECT, EXERCISE, LESSON, QUIZ
- `cohort` — id numérico del cohorte
- `limit`, `offset` — paginación

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/admissions/user/me"
# Responde con id, email, nombre, cohorts, roles — confirma token activo
```

### 2. Proyectos (PROJECT) — Skill 2: Obtener mis proyectos

Endpoints relacionados: `GET /v1/assignment/user/me/task` con `task_type=PROJECT`

Filtros:
- `task_type=PROJECT` — solo proyectos (no ejercicios ni lecciones)
- `task_status` — PENDING, DONE, APPROVED, REJECTED
- `cohort` — id numérico del cohorte
- `limit`, `offset` — paginación

**Prueba que funciona:**
```bash
# Proyectos pendientes
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/assignment/user/me/task?task_type=PROJECT&task_status=PENDING"
# → Devuelve 13 proyectos pendientes (al 2026-09-09)

# Proyectos completados (DONE)
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/assignment/user/me/task?task_type=PROJECT&task_status=DONE"
# → Devuelve 11 proyectos completados
```

### 3. Trabajo pendiente por cohorte — Skill 3: Obtener trabajo pendiente

Endpoints relacionados: `GET /v1/admissions/user/me` (campo `cohorts[].completion`)

Devuelve, para cada cohorte activo:
- Progreso general: `overall.completed` / `overall.total` (`overall.percent`)
- Proyectos faltantes obligatorios: `required.PROJECT.missing` (lista de slugs)
- Conteo total pendiente: `pending_required_count`
- Estado educativo: `educational_status` (ACTIVE, GRADUATED, etc.)

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/admissions/user/me" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
for c in data.get('cohorts', []):
    name = c['cohort']['name']
    status = c['educational_status']
    comp = c.get('completion', {})
    ov = comp.get('overall', {})
    pend = comp.get('pending_required_count', 0)
    print(f'{name} ({status}): {ov.get(\"completed\",0)}/{ov.get(\"total\",0)} ({ov.get(\"percent\",0)}%) — {pend} pendientes')
    slugs = comp.get('pending_required_slugs', {})
    for t, s in slugs.items():
        for slug in s:
            print(f'  - [{t}] {slug}')
"
# → Ejemplo: "Advanced personal assitants with Openclaw (ACTIVE): 0/2 (0.0%) — 2 pendientes"
#   - [PROJECT] openclaw-integration
#   - [PROJECT] openclaw-skills
```

### 4. Resumen de progreso — Skill 4: Obtener resumen de progreso

Endpoints relacionados: `GET /v1/admissions/user/me` (campo `cohorts`)

Procesa todos los cohortes del usuario para dar una visión general:

| Métrica | Descripción |
|---|---|
| Total cohortes | Cantidad total de cohortes inscritos |
| Graduados | Cohortes con `educational_status = GRADUATED` |
| Activos | Cohortes cursando actualmente |
| Progreso consolidado | `completed / total` de todas las tareas sumadas |
| Completados al 100% | Cohortes donde `overall.completed == overall.total` |

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/admissions/user/me" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
cohorts = data.get('cohorts', [])
total = len(cohorts)
grad = sum(1 for c in cohorts if c.get('educational_status') == 'GRADUATED')
active = sum(1 for c in cohorts if c.get('educational_status') == 'ACTIVE')
t_tasks = sum(c.get('completion',{}).get('overall',{}).get('total',0) for c in cohorts)
c_tasks = sum(c.get('completion',{}).get('overall',{}).get('completed',0) for c in cohorts)
pct = (c_tasks / t_tasks * 100) if t_tasks > 0 else 0
cc = sum(1 for c in cohorts if c.get('completion',{}).get('overall',{}).get('total',0) > 0 and c.get('completion',{}).get('overall',{}).get('completed',0) == c.get('completion',{}).get('overall',{}).get('total',0))
print(f'Cohortes: {total} ({grad} graduados, {active} activos)')
print(f'Progreso: {c_tasks}/{t_tasks} ({pct:.1f}%)')
print(f'Completados al 100%: {cc}')
"
# → Cohortes: 41 (6 graduados, 35 activos)
#   Progreso: 11/122 (9.0%)
#   Completados al 100%: 4
```

### 5. Detalle de una tarea

`GET /v1/assignment/task/{task_id}` — detalle completo con descripción,
puntuación y feedback.

### 6. Actualizar URLs de entrega

`PUT /v1/assignment/task/{task_id}` — actualizar `github_url` y/o `live_url`.

### 7. Entregar tarea para revisión

`POST /v1/assignment/task/{task_id}/deliver` — marca como entregada.

### 8. Perfil del usuario

`GET /v1/admissions/user/me` — datos personales y academias vinculadas.

### 9. Cohortes del usuario

`GET /v1/admissions/academy/cohort/me` — cohortes activos (`educational_status`).

### 10. Certificados

`GET /v1/certificate/` — lista de certificados (opcional `cohort`).

### 11. Recomendar ejercicios/práctica — Skill 5: Recomendarme qué practicar

Endpoints relacionados: `GET /v1/registry/asset`

Catálogo de contenido filtrable por:
- `technologies` — slug de tecnología (ej: python, react, javascript)
- `difficulty` — BEGINNER, EASY, INTERMEDIATE, HARD
- `asset_type` — LESSON, EXERCISE, PROJECT, QUIZ, STARTER
- `like` — búsqueda por texto
- `limit`, `offset` — paginación

La respuesta incluye: `count` (total), `results[]` con título, slug, tipo, dificultad, tecnologías, readme_url, etc.

**Prueba que funciona:**
```bash
# Buscar ejercicios de Python para principiantes
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/registry/asset?technologies=python&difficulty=BEGINNER&asset_type=EXERCISE&limit=5" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f'Disponibles: {data[\"count\"]}')
for a in data['results']:
    print(f'  [{a[\"asset_type\"]}] {a[\"title\"]}')
    print(f'    slug: {a[\"slug\"]} | dificultad: {a[\"difficulty\"]}')
"
# → Disponibles: 68 (sin filter EXERCISE) → resultados filtrados
```

También disponible: `GET /v1/registry/asset/{asset_slug}` — detalle completo del asset (readme, descripción, repositorio).
Y: `GET /v1/registry/technology` — lista de tecnologías disponibles.

### 12. Eventos del campus — Skill 6: Ver eventos próximos

Endpoints relacionados: `GET /v1/events/all`

Filtros:
- `upcoming=true` — solo eventos futuros
- `academy` — id numérico de la academia (7 = Latam, 6 = Madrid)
- `limit` — cantidad de resultados

Respuesta: lista de objetos con título, slug, fecha de inicio, academia, descripción, etc.

**Prueba que funciona:**
```bash
# Próximos eventos en todas las academias
curl -sL -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/events/all?upcoming=true&limit=10" | \
  python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f'Próximos eventos: {len(data)}')
for e in data:
    print(f'  📅 {e[\"title\"]}')
    print(f'     inicio: {e.get(\"starting_at\",\"?\")[:16]}')
"
# → Próximos eventos: 2
#   📅 Vibe Coding in Python: From Beginner to First Project
#      inicio: 2026-09-10T17:30
#   📅 IA en el mundo real de hoy
#      inicio: 2026-09-30T17:00
```

También se puede filtrar por academia: `?academy=7&upcoming=true` para solo eventos de 4Geeks Latam.

## Tarea rápida: consultar mis tareas pendientes

```bash
curl -sL \
  -H "Authorization: Token $TOKEN_4GEEKS" \
  "https://breathecode.herokuapp.com/v1/assignment/user/me/task?task_status=PENDING"
```

## Notas

- El token se maneja vía variable de entorno, no está hardcodeado.
- Los endpoints que no requieren token están marcados como públicos en el doc.
- Para filtrar por academia se usa `academy_id` (de `profile_academy` en perfil).
- Paginación con `limit` y `offset` en listados.
- Evitar ráfagas de requests — cachear respuestas estables.