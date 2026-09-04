# TOOLS.md - Local Notes (Optimus / Jonathan)

Skills definen *cómo* funcionan las tools. Este archivo es el cheat sheet del entorno real.

## Environment

- Host: VPS Linux (SSH), trabajo habitual vía **VS Code Remote SSH**
- OpenClaw state/workspace: `~/.openclaw/` y `~/.openclaw/workspace/`
- Agente: **Optimus Prime** (main)
- Canal principal de chat: **Telegram**
- Timezone por defecto: **America/Mexico_City (UTC-6)**

## Accounts (preferidas)

- **Google (Docs / Drive / archivos, p. ej. flujos Shopify):** `shopify.aleph7k@gmail.com`
- **Zapier:** `aleph_7k@hotmail.com`
- No guardar tokens, passwords ni client secrets en este archivo.

## Google (Docs / Drive / Calendar)

- Crear o listar Docs/Drive/Calendar solo si hay tool real disponible (p. ej. `gog` u otra skill de Google) y auth válida.
- Cuenta por defecto para archivos: `shopify.aleph7k@gmail.com`
- Convención de nombres de prueba: prefijo `Prueba Optimus` o `E2E Optimus`
- Siempre devolver **link real** (`docs.google.com` / evento) cuando se cree algo; no afirmar éxito sin evidencia.
- Telegram es solo el canal de mensajes; **no** implica acceso a Google por sí solo.

## Calendar

- Timezone de eventos: America/Mexico_City
- Si falta zona horaria en una tarea menor, asumir México (UTC-6) y continuar
- Para pruebas E2E: títulos claros tipo `Prueba E2E Optimus`

## Zapier / MCP

- Cuenta Zapier de referencia: `aleph_7k@hotmail.com`
- Antes de decir "Zapier conectado", verificar config real:
  - `openclaw mcp list`
  - `openclaw config get mcp`
- Para evidencia de entrega: captura de MCP + un flujo que use la tool (no solo mencionar Zapier).

## Telegram

- Canal operativo principal con Jonathan
- Usar para conversación, pedidos y demos; las acciones en Google/Zapier dependen de tools en el VPS
- No compartir datos sensibles de Jonathan en grupos

## Workspace paths

- Identity / soul / user: `~/.openclaw/workspace/IDENTITY.md`, `SOUL.md`, `USER.md`
- Agent rules: `~/.openclaw/workspace/AGENTS.md`
- Notes de entrega: `notes.md` (en el repo de entrega cuando aplique)
- Memoria diaria: `~/.openclaw/workspace/memory/YYYY-MM-DD.md`
- Memoria larga: `~/.openclaw/workspace/MEMORY.md` (solo sesión main privada)

## Git / entrega

- Verificar siempre en el repo correcto (`pwd`, `git status`)
- Guardar archivos en el editor antes de `git add`
- Comprobar contenido real con `cat` / `git show HEAD:archivo` si GitHub muestra vacío

## Conventions

- Un comando a la vez cuando Jonathan esté depurando en terminal
- Preferir verificación en disco a afirmaciones en chat
- Separar: identidad del agente vs auth Google vs canal Telegram vs MCP/Zapier
- No recomendar servicios de pago sin aprobación explícita

## Out of scope (por ahora)

- Detalles de cámaras, TTS, speakers o red local doméstica: N/A en este VPS
- HEARTBEAT.md: se configurará después
