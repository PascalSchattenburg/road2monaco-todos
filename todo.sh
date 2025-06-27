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

echo "Was möchtest du tun?"
echo "1) Neues ToDo hinzufügen"
echo "2) Nutzer entfernen"
echo "3) Abbrechen"
read -p "Auswahl: " CHOICE

if [[ "$CHOICE" == "1" ]]; then
  echo "— Eingetragene Nutzer —"
  jq -r '.[].owner' "$TODO_FILE" | sort -u | nl
  read -p "Gib den Namen des Nutzers ein (oder neuen Namen): " OWNER
  read -p "ToDo: " TEXT
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

elif [[ "$CHOICE" == "2" ]]; then
  echo "— Eingetragene Nutzer —"
  jq -r '.[].owner' "$TODO_FILE" | sort -u | nl
  read -p "Welchen Nutzer möchtest du entfernen? (Name eingeben): " DELETE_USER

  TMP_FILE=$(mktemp)
  jq "del(.[] | select(.owner == \"$DELETE_USER\"))" "$TODO_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$TODO_FILE"

  echo "🗑️ Alle Todos von '$DELETE_USER' wurden gelöscht."

  # Git Push
  git config user.name "$GIT_USER"
  git config user.email "$GIT_EMAIL"
  git add "$TODO_FILE"
  git commit -m "remove todos by: $DELETE_USER"
  git push

elif [[ "$CHOICE" == "3" ]]; then
  echo "Abgebrochen."
  exit 0

else
  echo "Abgebrochen."
  exit 0
fi