#!/bin/bash

TODO_FILE="todos.json"
GIT_USER="todo-bot"
GIT_EMAIL="todo@example.com"

# Prüfen ob jq installiert ist
if ! command -v jq &> /dev/null; then
  echo "Fehler: 'jq' ist nicht installiert."
  exit 1
fi

# Wenn Datei nicht existiert
if [ ! -f "$TODO_FILE" ]; then
  echo "[]" > "$TODO_FILE"
fi

# Prüfen ob Eingabetext vorhanden ist
if [ "$#" -lt 1 ]; then
  echo "❌ Bitte gib den Text für das ToDo direkt mit dem Befehl an, z. B.: ./todo.sh \"Einkaufen gehen\""
  exit 1
fi

TEXT="$*"

# Nutzer vorschlagen
USERS=($(jq -r '.[].owner' "$TODO_FILE" | sort -u))
if [ ${#USERS[@]} -eq 0 ]; then
  echo "⚠️  Keine Nutzer vorhanden. Bitte gib einen neuen Namen ein."
  read -p "Neuer Nutzername: " OWNER
else
  read -p "Wähle Nutzer (${USERS[*]}): " OWNER
fi

read -p "Wichtig? (j/n): " ANTWORT
if [[ "$ANTWORT" == "j" ]]; then
  IMPORTANT=true
else
  IMPORTANT=false
fi

NEW_ENTRY="{\"owner\": \"$OWNER\", \"text\": \"$TEXT\", \"done\": false, \"important\": $IMPORTANT}"

TMP_FILE=$(mktemp)
jq ". + [$NEW_ENTRY]" "$TODO_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$TODO_FILE"

echo "✅ Neuer Eintrag gespeichert:"
echo "$NEW_ENTRY"

# Git Push
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"
git add "$TODO_FILE"
git commit -m "add todo: $OWNER – $TEXT"
git push