# Notes
### Decisiones de configuración y problemas relevantes

* El primer rechazo de la entrega ocurrió porque faltaba el **Greeting** en `IDENTITY.md`; además, el agente afirmaba haber modificado el archivo aunque el cambio no aparecía realmente en disco.
* No podía usar comandos de git - `git status`- hasta que vi que era porque fuera del repositorio correcto (`~/.openclaw/workspace`).
* Use una cuenta personal para el proyecto, creí que tenía que comenzar desde 0 pero el cambio fue rápido con Zapier
* Al subir el proyecto, GitHub devolvió **403** porque VS Code estaba autenticado con una cuenta incorrecta; cambié la sesión a **`aleph27k`** y resolví posteriormente un conflicto de `README.md` mediante `git pull --rebase`.
* Finalmente moví la entrega al repositorio **`4GeeksAcademy/openclaw-alephk27`** y verifiqué que no se hubieran publicado `openclaw.json`, `.env`, API keys, tokens ni archivos de credenciales.
* **Extra**: subí el archivo notes.md con comentarios, hice git push, pero el archivo apareció solo, así que agregué esta línea extra y voy a intentar otra vez.