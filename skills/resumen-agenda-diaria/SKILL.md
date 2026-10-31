---
name: resumen-agenda-diaria
description: Consulta los eventos de hoy en el Google Calendar ya conectado mediante Zapier y presenta un resumen cronológico en español. Usar cuando Jonathan pregunte qué tiene hoy, cuál es su agenda o qué eventos tiene en una fecha.
---

# Resumen de agenda diaria

Consulta Calendar únicamente mediante la conexión de Zapier ya configurada. No crees eventos ni configures credenciales, APIs u OAuth.

## Procedimiento

1. Interpreta la fecha solicitada. Si Jonathan no especifica una, usa hoy en `America/Mexico_City`.
2. Construye el inicio inclusivo y fin exclusivo del día en esa zona horaria. Si la herramienta espera timestamps RFC 3339, incluye el offset correcto para la fecha consultada; no supongas que UTC-6 aplica durante todo el año.
3. Usa la acción de lectura de Calendar disponible en Zapier. La integración existente en este workspace ha usado `GoogleCalendarCLIAPI`, acción `event_v2` y herramienta `google_calendar_find_events`; reutilízala solo si aparece disponible. No adivines nombres de herramientas ni parámetros: si falta o cambió, inspecciona las herramientas existentes de Zapier y utiliza el esquema devuelto.
4. Ordena los eventos por hora de inicio. Incluye hora local, título y ubicación o detalle breve cuando esté disponible. Identifica eventos de día completo por separado.
5. Responde en Telegram/chat con un listado conciso en español. Si no hay eventos, indícalo claramente.

## Seguridad y verificación

- Es una operación de lectura: no modifiques, crees ni canceles eventos.
- No afirmes que Calendar respondió correctamente si la herramienta devuelve error o una respuesta que no puedas interpretar. Explica el bloqueo sin revelar datos sensibles.
- No envíes un mensaje adicional directamente mediante la API de Telegram: responde en el canal actual.
- Sigue el tono directo, claro y amigable de `SOUL.md`; usa la zona horaria y cuenta preferida descritas en `USER.md` y `TOOLS.md` cuando la conexión ya las tenga disponibles.
