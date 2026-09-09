# SKILL_LOG.md

Registro de skills creadas / modificadas y las conversaciones que las originaron.

---

## [2026-09-08] authenticate-4geeks — Skill inicial (scaffold)

**Origen:** Conversación en webchat, Jonathan pidió crear el archivo vacío `skills/authenticate-4geeks.md`

**Acción:** Creación de archivo vacío y registro en `openclaw.json`:
```json
"skills": {
  "entries": {
    "authenticate-4geeks": {
      "enabled": true,
      "env": {
        "TOKEN_4GEEKS": "${TOKEN_4GEEKS}"
      }
    }
  }
}
```

---

## [2026-09-09] authenticate-4geeks — Skill funcional (Estado de tareas)

**Origen:** Conversación en webchat.
Jonathan compartió la documentación oficial:
https://github.com/4GeeksAcademy/ai-engineering-syllabus/blob/main/content/projects/openclaw-integration/STUDENT_API_CALLS_REFERENCE.es.md

**Acción:** Refactorización completa de la skill:
- Se movió de archivo plano `skills/authenticate-4geeks.md` → directorio `skills/authenticate-4geeks/SKILL.md`
- Se documentaron todos los endpoints de la API de BreatheCode
- Se priorizó la sección de **Estado de tareas (task_status)**: PENDING, DONE, APPROVED, REJECTED
- Se incluyen filtros, paginación, ejemplos de uso

**Próximas skills planeadas:**
- Entregar tareas (deliver)
- Consultar actividad/progreso
- Catálogo de assets (buscar ejercicios/lecciones)
- Certificados

---

## [2026-09-09] Conversacion de Descubrimiento

**Origen:** Jonathan pidió: *"ayudame a conectarme a la API de 4Geeks usando mi token"*

**Contexto previo:** La sesión de ayer (2026-09-08) dejó el token `BC_TOKEN` configurado en `~/.bashrc` y `openclaw.json`. El gateway fue reiniciado.

**Desarrollo:**
1. Se verificó que `BC_TOKEN` seguía disponible en el environment
2. Se ejecutó `curl` contra `GET /v1/admissions/user/me` — respuesta exitosa ✅
3. Se confirmó identidad: **JONATHAN OBED LEDEZMA ESPINOZA** (`aleph_7k@hotmail.com`)
4. Se ejecutó `GET /v1/assignment/user/me/task?task_status=PENDING` — **52 tareas pendientes** encontradas
5. Se desglosaron por cohorte y tipo (11 PROJECT, resto EXERCISE/LESSON)
6. Se detectaron cohortes completados al 100% (FastAPI, Intro to AI)

**Resultado: Conexión funcional.** Desde el chat se pueden consultar:
- Tareas por estado (PENDING, DONE, APPROVED, REJECTED)
- Perfil y cohortes
- Actividad, certificados, catálogo de assets
- Detalle de tareas y entregas

**Conclusión:** La API de 4Geeks Academy (BreatheCode) está operativa con el token de estudiante. No se requiere acción adicional de Jonathan para consultas futuras.

---

## [2026-09-09] Skill 1: Autenticar — Conexión a API 4Geeks

**Solicitud en lenguaje natural:**
> *"ayudame a conectarme a la API de 4Geeks usando mi token"*

**Skill que OpenClaw ayudó a crear:**
- `authenticate-4geeks/SKILL.md` — Sección "Tareas por estado (task_status)"
- Capacidad de verificar que el token es válido y que la sesión está activa consultando `GET /v1/admissions/user/me`
- Configuración de `BC_TOKEN` en `~/.bashrc` y mapeo a `TOKEN_4GEEKS` en `openclaw.json`

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $BC_TOKEN" \
  "https://breathecode.herokuapp.com/v1/admissions/user/me"
```
✅ Responde con `id: 21639`, `email: aleph_7k@hotmail.com`, `first_name: JONATHAN OBED` — token activo.

---

## [2026-09-09] Skill 2: Obtener mis proyectos

**Solicitud en lenguaje natural:**
> *"haz una skill que pueda recuperar la lista de proyectos asignados con su estado actual (pendiente, entregado, calificado)"*

**Skill que OpenClaw ayudó a crear:**
- `authenticate-4geeks/SKILL.md` — Sección "Proyectos (PROJECT) — Skill 2: Obtener mis proyectos"
- Documentación de filtros `task_type=PROJECT` combinado con `task_status`
- Endpoints documentados con pruebas reales verificadas

**Prueba que funciona:**
```bash
# Proyectos PENDING
curl -sL -H "Authorization: Token $BC_TOKEN" \
  "https://breathecode.herokuapp.com/v1/assignment/user/me/task?task_type=PROJECT&task_status=PENDING"
```
✅ Devuelve **13 proyectos pendientes** (al 2026-09-09) con título, cohorte y fecha de creación.
```bash
# Proyectos DONE
curl -sL -H "Authorization: Token $BC_TOKEN" \
  "https://breathecode.herokuapp.com/v1/assignment/user/me/task?task_type=PROJECT&task_status=DONE"
```
✅ Devuelve **11 proyectos completados**.

---

## [2026-09-09] Skill 3: Obtener trabajo pendiente

**Solicitud en lenguaje natural:**
> *"el agente puede decirte específicamente qué te falta completar"*

**Skill que OpenClaw ayudó a crear:**
- `authenticate-4geeks/SKILL.md` — Sección "Trabajo pendiente por cohorte — Skill 3"
- Extrae del perfil del usuario (`GET /v1/admissions/user/me`) el campo `cohorts[].completion`
- Muestra progreso general, proyectos faltantes obligatorios y conteo pendiente por cohorte

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $BC_TOKEN" \
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
    print(f'{name} ({status}): {ov.get(\"completed\",0)}/{ov.get(\"total\",0)} — {pend} pendientes')
"
```
✅ Devuelve desglose por cohorte con progreso exacto y slugs de lo que falta completar.

---

## [2026-09-09] Skill 4: Obtener resumen de progreso

**Solicitud en lenguaje natural:**
> *"OpenClaw puede darte una visión general de cuanto has avanzado en el curso"*

**Skill que OpenClaw ayudó a crear:**
- `authenticate-4geeks/SKILL.md` — Sección "Resumen de progreso — Skill 4"
- Consolida todos los cohortes del usuario en una vista general
- Calcula: total cohortes, graduados, activos, progreso global (completados/totales), completados al 100%

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $BC_TOKEN" \
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
print(f'Completados al 100\\%: {cc}')
"
```
✅ Responde con resumen completo: 41 cohortes, 6 graduados, 35 activos, 11/122 (9.0%), 4 completados al 100%.

---

## [2026-09-09] Skill 5: Recomendarme qué practicar

**Solicitud en lenguaje natural:**
> *"recomiéndame ejercicios de Python nivel intermedio"*

**Skill que OpenClaw ayudó a crear:**
- `authenticate-4geeks/SKILL.md` — Sección "Recomendar ejercicios/práctica — Skill 5"
- Usa `GET /v1/registry/asset` con filtros: `technologies`, `difficulty`, `asset_type`, `like`
- También documenta `GET /v1/registry/technology` para descubrir tecnologías disponibles
- `GET /v1/registry/asset/{asset_slug}` para detalle completo del asset

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $BC_TOKEN" \
  "https://breathecode.herokuapp.com/v1/registry/asset?technologies=python&difficulty=BEGINNER&limit=5"
```
✅ Devuelve 68 assets de Python nivel BEGINNER con título, slug, tipo, dificultad y tecnologías.

---

## [2026-09-09] Skill 6: Mi actividad semanal (ELIMINADA ❌)

**Solicitud en lenguaje natural:**
> *"cómo voy esta semana"*

**Estado:** Eliminada de SKILL.md.

**Motivo:** El token de estudiante no tiene permiso `read_activity`. Los endpoints de actividad (`GET /v1/activity/me`, `GET /v1/activity/cohort/{id}`) devuelven 403.

**Alternativa documentada:** Skills 3 y 4 usan `GET /v1/admissions/user/me` para obtener progreso y trabajo pendiente.

---

## [2026-09-09] Skill 6 (nueva): Ver eventos próximos

**Solicitud en lenguaje natural:**
> *"qué eventos hay esta semana"*

**Skill que OpenClaw ayudó a crear:**
- `authenticate-4geeks/SKILL.md` — Sección "Eventos del campus — Skill 6 (nueva)"
- Usa `GET /v1/events/all` con filtros `upcoming=true` y `academy`
- No requiere permisos adicionales, funciona con token de estudiante ✅

**Prueba que funciona:**
```bash
curl -sL -H "Authorization: Token $BC_TOKEN" \
  "https://breathecode.herokuapp.com/v1/events/all?upcoming=true&limit=5"
```
✅ Devuelve 2 eventos próximos: "De Vuelta al Buscador de Empleo con IA" (2026-09-10) y "El mapa real del AI Engineer" (2026-09-30).