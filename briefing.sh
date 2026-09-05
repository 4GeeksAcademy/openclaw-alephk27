#!/bin/bash
# Briefing diario 5PM - script para cron --command
# Consulta Google Calendar via MCP y envía a Telegram
set -e

DATE=$(date +%Y-%m-%d)
CHAT_ID="8561583067"

# Obtener eventos del día via mcporter
EVENTS=$(mcporter call zapier.execute_zapier_read_action \
  selected_api="GoogleCalendarCLIAPI" \
  action="event_v2" \
  tool_name="google_calendar_find_events" \
  "params={\"calendarid\":\"shopify.aleph7k@gmail.com\",\"timeMin\":\"${DATE}T00:00:00-06:00\",\"timeMax\":\"${DATE}T23:59:00-06:00\",\"expand_recurring\":\"no\"}" 2>&1)

# Extraer bot token de openclaw.json
TOKEN=$(cat /root/.openclaw/openclaw.json | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('channels',{}).get('telegram',{}).get('botToken',''))")

# Contar eventos
COUNT=$(echo "$EVENTS" | python3 -c "
import json,sys
try:
    d=json.load(sys.stdin)
    r=d.get('results',d if isinstance(d,list) else [])
    print(len(r))
except:
    print(0)
")

if [ "$COUNT" = "0" ]; then
  TEXT="📅 *Briefing diario*%0A%0ASin compromisos hoy 📭"
else
  TEXT=$(echo "$EVENTS" | python3 -c "
import json,sys
d=json.load(sys.stdin)
r=d.get('results',d if isinstance(d,list) else [])
r.sort(key=lambda x: x.get('start',{}).get('dateTime',''))
L=['📅 *Briefing diario*','']
for i in r:
    s=i.get('start',{})
    t=s.get('dateTime_pretty',s.get('date','?'))
    L.append(f'🕐 {t} — {i.get(\"summary\",\"?\")}')
L.extend(['','_Generado automáticamente_'])
print('%0A'.join(L))
")
fi

# Enviar a Telegram
curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d "chat_id=${CHAT_ID}&text=${TEXT}&parse_mode=Markdown&disable_web_page_preview=true" | python3 -c "import json,sys; d=json.load(sys.stdin); print('OK' if d.get('ok') else 'FAIL: '+str(d))"
