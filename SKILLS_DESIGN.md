# Skill #1: Resumen de Agenda del Día (resumen-agenda-diaria)

## ¿Qué hace?
Consulta los eventos programados para el día actual en Google Calendar de Jonathan, los filtra y envía un reporte estructurado y limpio directamente a su chat de Telegram.

## Input del agente
Solicitud explícita en lenguaje natural sobre la agenda del día (ej. "¿qué tengo hoy?", "muéstrame mi agenda"). Requiere únicamente la intención — el día actual y el horario se obtienen automáticamente.

### Configuración conocida desde archivos:
- **USER.md** — timezone: `America/Mexico_City (UTC-6)`, cuenta principal: `shopify.aleph7k@gmail.com`
- **TOOLS.md** — canal de respuesta: Telegram
- **SOUL.md** — entregar evidencia verificable

## Output esperado
Mensaje de texto en Telegram con viñetas cronológicas indicando:
- Hora
- Título del evento
- Detalles relevantes

Ordenados del más temprano al más tarde. Si no hay eventos, mensaje claro de "sin compromisos hoy".

### Verificación de éxito
1. API de Google Calendar responde HTTP 200
2. Mensaje llega al chat de Telegram (confirmación de envío de Telegram API)

## Consideraciones
- **Eventos sin hora:** ignorar o agrupar como "sin hora asignada"
- **Recordatorios (reminders):** incluirlos solo si son breves para no saturar el reporte
- **Encadenable:** compatible con `crear-clase-calendar` (agenda del día vs. programar nueva clase)
---

# Skill #2: Briefing Diario Automático (briefing-diario-6am)

## ¿Qué hace?
Cada día, a las 6:00 AM (hora de Jonathan, America/Mexico_City UTC-6), envía automáticamente a Telegram un resumen con los eventos programados para hoy.

## Input del agente
Ninguno del usuario — es una ejecución automática vía `openclaw cron --command`.

### Implementación actual
Se usa un cron de tipo `command` que ejecuta el script `briefing.sh` en el workspace. El script:
1. Consulta Google Calendar via `mcporter` (MCP de Zapier)
2. Formatea la respuesta como viñetas cronológicas
3. Envía el mensaje directo a Telegram vía Bot API con `curl`

### Archivo de implementación
- **Script:** `~/.openclaw/workspace/briefing.sh`
- **Cron job:** `briefing-6am` (también puede crearse `briefing-5pm` con la misma configuración pero cron `0 6 * * *` / `0 17 * * *`)

## Output esperado
Mensaje de Telegram con el mismo formato del reporte de `resumen-agenda-diaria` (viñetas cronológicas con hora, título y detalles), entregado de forma proactiva.

### Verificación de éxito
1. El cron se ejecuta sin error (`status: ok`).
2. El script responde `OK` (la API de Telegram confirma `ok: true`).

## Consideraciones
- **Zona horaria:** configurar el trigger en UTC-6.
- **Días sin eventos:** enviar igual "No tienes compromisos hoy" para confirmar canal vivo.
- **vs resumen-agenda-diaria:** push automático vs bajo demanda. Comparten formato de reporte.
- **Modo `--no-deliver`:** el cron usa `--no-deliver` porque el script envía directo a Telegram vía curl, sin pasar por el delivery del gateway.
