#!/bin/bash

# Datei, in die ToDos geschrieben werden
TODO_FILE="todos.json"

# Git Konfig (optional anpassbar)
GIT_USER="todo-bot"
GIT_EMAIL="todo@example.com"

# Prüfen, ob jq installiert ist
if ! command -v jq &> /dev/null; then
  echo "Fehler: 'jq' ist nicht installiert. Bitte mit 'brew install jq' oder 'sudo apt install jq' installieren."
  exit 1
fi

# Parameter prüfen
if [ "$#" -lt 2 ]; then
  echo "Usage: ./todo.sh <owner> <todo text> [! or !! or !!!]"
  exit 1
fi

OWNER="$1"
shift

# Prüfen auf Prioritätszeichen am Ende
PRIORITY=0
LAST="$*"
if [[ "$LAST" =~ \!\!\!$ ]]; then
  PRIORITY=3
  TEXT="${LAST::-3}"
elif [[ "$LAST" =~ \!\!$ ]]; then
  PRIORITY=2
  TEXT="${LAST::-2}"
elif [[ "$LAST" =~ \!$ ]]; then
  PRIORITY=1
  TEXT="${LAST::-1}"
else
  TEXT="$LAST"
fi

# Leerzeichen am Ende entfernen
TEXT=$(echo "$TEXT" | sed 's/ *$//')

# JSON-Eintrag vorbereiten
NEW_ENTRY="{\"owner\": \"$OWNER\", \"text\": \"$TEXT\", \"done\": false, \"priority\": $PRIORITY}"

# Wenn Datei nicht existiert, initialisiere sie
if [ ! -f "$TODO_FILE" ]; then
  echo "[]" > "$TODO_FILE"
fi

# Neuen Eintrag anhängen mit jq
TMP_FILE=$(mktemp)
jq ". + [$NEW_ENTRY]" "$TODO_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$TODO_FILE"

echo "Neuer Eintrag wurde in $TODO_FILE geschrieben:"
cat "$TODO_FILE"

# Git Konfiguration
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"

# Commit und Push
git add "$TODO_FILE"
git commit -m "add todo: $OWNER – $TEXT"
git push