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

---

# Skill #3: Triaje de Bandeja de Entrada (triaje-gmail)

## ¿Qué hace?
Lee los correos no leídos de Gmail de Jonathan, identifica cuáles requieren acción y crea una Google Task por cada uno con una descripción breve de qué hay que hacer.

## Input del agente
Solo la solicitud de ejecutar el triaje (ej. "haz el triaje de mi correo"). El resto lo obtiene automáticamente y de los archivos de configuración:
- **USER.md** — cuenta Gmail: `shopify.aleph7k@gmail.com`, timezone: UTC-6, regla: no enviar correos ni gastar dinero sin confirmación (triaje solo crea Tasks, no envía nada — respeta el boundary).
- **TOOLS.md** — criterios y convenciones de qué cuenta es la principal.
- **AGENTS.md** — red lines: ignorar promociones y correos masivos.

## Output esperado
- Una **Google Task** por correo que requiere acción, con: asunto/título del correo, remitente, y descripción breve de la acción (ej. "Responder a X, solicita presupuesto").
- Se debe **confirmar primero en Telegram**: lista resumida de las Tasks que se crearán antes de crearlas (doble confirmación, no asumir que todo correo requiere acción).
- Luego crear las Tasks y mandar por Telegram el resumen con el número de Tasks creadas.

### Verificación de éxito
1. API de Google Tasks responde con éxito por cada tarea creada.
2. Resumen final llega a Telegram.

## Consideraciones
- **Priorizar:** marcar con prioridad media/alta las Tasks de correos urgentes (patrones tipo "ASAP", "vencimiento", "atender").
- **No duplicar:** si ya existe una Task del mismo correo, omitirla.
- **Futuro:** versión encadenable podría crear bloques de Calendar para estas Tasks (skill task → calendar del brief).

---

# Skill #4: Creación Inteligente de Clases en Calendario (crear-clase-calendar)

## ¿Qué hace?
Permite a Jonathan describir una sesión de estudio o clase en lenguaje natural (ej. "clase de programación el lunes a las 4 PM por dos horas") y genera el evento con los parámetros correctos en Google Calendar. Si la petición es "todo el día", crea un evento all-day (pestaña superior del día, sin hora).

## Input del agente
Una frase en lenguaje natural dictada por Telegram con la intención, el día y, si aplica, la hora y la duración. Ya sabe: timezone UTC-6, cuenta shopify.aleph7k@gmail.com, canal Telegram.

### Configuración conocida:
- **USER.md** — timezone: UTC-6, cuenta: `shopify.aleph7k@gmail.com`
- **TOOLS.md** — canal: Telegram; Calendar conectado vía Zapier como vía por defecto
- **AGENTS.md** — no proponer `.gog`/OAuth/Google API mientras exista integración conectada

## Modo all-day (detección automática, sin preguntar)
Si la frase incluye "todo el día", "día completo", "all day" o "sin hora", se activa modo all-day y NO se pregunta por hora ni duración.

**Cambio de payload:**
- **NORMAL** → `start.dateTime` + `end.dateTime` + `timeZone` (UTC-6)
- **ALL-DAY** → `start.date: "YYYY-MM-DD"`, `end.date: "YYYY-MM-DD"` (siguiente día). Omite `dateTime` y `timeZone` por completo.

Nota: `end.date` es exclusivo (evento de un día va del 7 al 8).

## Output esperado
Un único mensaje de Telegram con confirmación:
- **Normal:** ✅ Evento creado: *<título>* — lun 7 sep, 16:00–18:00 (UTC-6). Link: `<calendar.google.com/...>`
- **All-day:** ✅ Evento all-day creado: *<título>* — 7 sep. Link: `<calendar.google.com/...>`

### Verificación de éxito
La API responde con ID/link del evento (date-only si fue all-day) y llega un solo mensaje a Telegram. Nunca afirmar éxito sin el link.

## Reglas duras (no divagar)
1. Detectar all-day ANTES de crear el evento; si aplica, nunca preguntar hora/duración.
2. Un solo mensaje de salida, sin streaming de "estoy pensando…".
3. Priorizar integración de Calendar ya conectada; `.gog`/OAuth/Google API solo si falla y reportando el bloqueo.
4. **Falla segura:** si dice "todo el día" pero da una hora específica ("reunión el lunes todo el día a las 3"), NO es all-day — prioriza la hora y avísalo en el mismo mensaje final.

---

# Skill #5: Listar Tareas 4Geeks (listar-tareas-4geeks)

## ¿Qué hace?
Obtiene la lista completa de tareas del usuario `jonathan` desde la API REST de 4Geeks Todo y la muestra ordenada, indicando cuáles están pendientes y cuáles completadas.

## Input del agente
Una frase como "muéstrame mis tareas", "qué tengo pendiente" o "lista de tareas". No necesita más datos.

### Configuración conocida:
- **USER.md** — usuario `jonathan`, endpoint: `https://playground.4geeks.com/todo/users/jonathan`
- **TOOLS.md** — canal de respuesta: Telegram
- **AGENTS.md** — operación segura (solo GET, no modifica nada)

## Output esperado
Mensaje estructurado con total y cada tarea con ID, estado y descripción:

```
📋 Tus tareas (4):

  ⏳ [1] tarea de ejemplo1
  ⏳ [2] hacer tarea de ejemplo 2
  ✅ [3] terminar clase de 4 Geeks
  ⏳ [4] Ponerme al dia con los trabajos

Pendientes: 3 | Completadas: 1
```

### Verificación de éxito
API responde HTTP 200 con array de tareas. Mensaje llega a Telegram.

---

# Skill #6: Crear Tarea 4Geeks (crear-tarea-4geeks)

## ¿Qué hace?
Crea una nueva tarea en la API de 4Geeks Todo para el usuario `jonathan`, con estado `is_done: false` por defecto.

## Input del agente
Una frase como "agrega estudiar Python a mis tareas", "crea tarea: comprar despensa" o "nueva tarea: terminar proyecto".

### Configuración conocida:
- **USER.md** — usuario `jonathan`, endpoint POST: `https://playground.4geeks.com/todo/todos/jonathan`
- **TOOLS.md** — canal de respuesta: Telegram
- **SOUL.md** — confirmar antes de escribir si hay ambigüedad

### Formato del POST
```json
{
  "label": "texto de la tarea",
  "is_done": false
}
```

## Output esperado
```
✅ Tarea creada (#5): estudiar Python
```

## Reglas
- **Sin confirmación extra:** si el texto es claro, crear directo (operación segura, no destructiva).
- **Si no se entiende el texto** (ej. solo "agrega una tarea"), preguntar antes.
- **Sin títulos vacíos:** si el label queda muy corto o ambiguo, pedir aclaración.

### Verificación de éxito
API responde HTTP 201/200 con el objeto de la tarea creada (incluyendo `id`). Mensaje llega a Telegram.
