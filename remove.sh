#!/bin/bash

TODO_FILE="todos.json"
GIT_USER="todo-bot"
GIT_EMAIL="todo@example.com"

# Prüfen, ob jq installiert ist
if ! command -v jq &> /dev/null; then
  echo "Fehler: 'jq' ist nicht installiert. Bitte installiere es mit 'brew install jq' oder 'sudo apt install jq'"
  exit 1
fi

# Wenn Datei nicht existiert
if [ ! -f "$TODO_FILE" ]; then
  echo "Die Datei $TODO_FILE existiert nicht."
  exit 1
fi

# Todo-Liste anzeigen
echo "Aktuelle Todos:"
jq -c '.[]' "$TODO_FILE" | nl -w2 -s'. ' | while read -r line; do
  number=$(echo "$line" | cut -d. -f1)
  content=$(echo "$line" | cut -d. -f2-)
  owner=$(echo "$content" | jq -r '.owner')
  text=$(echo "$content" | jq -r '.text')
  echo "[$number] $owner: $text"
done

# Auswahl abfragen
echo ""
read -p "Welche Nummer möchtest du löschen? " ID

if ! [[ "$ID" =~ ^[0-9]+$ ]]; then
  echo "Ungültige Eingabe."
  exit 1
fi

INDEX=$((ID - 1))

# Element löschen
TMP_FILE=$(mktemp)
jq "del(.[$INDEX])" "$TODO_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$TODO_FILE"

echo "Eintrag [$ID] wurde entfernt."

# Git-Änderung
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"

git add "$TODO_FILE"
git commit -m "removed todo [$ID]"
git push