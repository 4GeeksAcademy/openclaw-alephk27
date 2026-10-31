---
name: crear-clase-calendar
description: Crea una clase o sesión de estudio en el Google Calendar conectado mediante Zapier a partir de una solicitud clara de Jonathan. Usar cuando pida agendar una clase, sesión o evento.
---

# Crear clase en Calendar

Crea eventos solo usando la integración de Calendar ya conectada en Zapier. No configures conexiones, credenciales, APIs externas ni flujos OAuth.

## Procedimiento

1. Extrae de la solicitud el título y la fecha. Usa `America/Mexico_City` como zona horaria, según `USER.md` y `TOOLS.md`.
2. Si Jonathan dice “todo el día”, “día completo” o “all day” y no proporciona hora específica, crea evento de día completo. Si no indica hora ni solicita explícitamente todo el día, pregunta la hora y duración antes de crear. Si indica fecha ambigua, solicita aclaración.
3. Antes de escribir, verifica que dispones de una acción existente de creación de eventos de Google Calendar. Reutiliza `GoogleCalendarCLIAPI` mediante Zapier solo si aparece disponible; inspecciona el esquema actual para confirmar selector, argumentos, formato de fecha y cuenta conectada. No inventes nombres ni parámetros. Si la acción no está habilitada, detente e informa del bloqueo; no conectes otro servicio.
4. Para un evento con hora, proporciona fecha/hora de inicio y fin con la zona horaria apropiada. Para un evento all-day de una fecha, usa fecha inicial y fecha final exclusiva (el día siguiente), según el esquema de la acción.
5. Crea un solo evento después de resolver los datos necesarios. Si el conector ofrece previsualización y la petición es ambigua, muestra el resumen y espera confirmación antes de escribir.
6. Solo confirma la creación si la herramienta devuelve resultado exitoso. Informa título, fecha, horario local o condición all-day y enlace/identificador si fue devuelto.

## Reglas de seguridad

- No envíes correos ni publiques mensajes externos. Responde con la confirmación en el canal actual; no llames Telegram directamente.
- No crees duplicados por reintentos: ante una respuesta incierta, verifica el resultado antes de volver a crear.
- Respeta `AGENTS.md` y `SOUL.md`: ante ambigüedad, efectos externos inciertos o una solicitud destructiva, pregunta antes de actuar; nunca afirmes éxito sin evidencia.
- No expongas credenciales ni inventes accesos. Si la integración existente no está disponible, reporta el bloqueo sin proponer OAuth nuevo.
