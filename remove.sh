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

# Aktuelle Liste anzeigen
echo "Aktuelle Todos:"
jq -c '.[]' "$TODO_FILE" | nl -w2 -s'. ' | while read -r line; do
  number=$(echo "$line" | cut -d. -f1)
  content=$(echo "$line" | cut -d. -f2-)
  owner=$(echo "$content" | jq -r '.owner')
  text=$(echo "$content" | jq -r '.text')
  echo "[$number] $owner: $text"
done

# Prüfen, ob Argumente übergeben wurden
if [ "$#" -eq 0 ]; then
  echo ""
  read -p "Welche Nummer(n) möchtest du löschen (z. B. 1 3 5) um alle zu löschen (alle)? " -a IDS

else
  IDS=("$@")
fi

# "alle" als Argument erlaubt das Löschen aller Einträge
if [[ "${#IDS[@]}" -eq 1 && "${IDS[0]}" == "alle" ]]; then
  read -p "⚠️  Bist du sicher, dass du ALLE Todos löschen willst? (y/n): " CONFIRM
  if [[ "$CONFIRM" == "y" ]]; then
    echo "[]" > "$TODO_FILE"
    git config user.name "$GIT_USER"
    git config user.email "$GIT_EMAIL"
    git add "$TODO_FILE"
    git commit -m "removed all todos"
    git push
    echo "✔ Alle Todos wurden gelöscht."
    exit 0
  else
    echo "❌ Abgebrochen."
    exit 1
  fi
fi

# Sortiere und lösche rückwärts
TMP_FILE=$(mktemp)
cp "$TODO_FILE" "$TMP_FILE"

for ID in $(printf '%s\n' "${IDS[@]}" | sort -nr); do
  if [[ "$ID" =~ ^[0-9]+$ ]]; then
    INDEX=$((ID - 1))
    jq "del(.[$INDEX])" "$TMP_FILE" > "${TMP_FILE}.tmp" && mv "${TMP_FILE}.tmp" "$TMP_FILE"
    echo "✔ [$ID] Eintrag gelöscht"
  else
    echo "❌ Ungültige Nummer: $ID"
  fi
done

mv "$TMP_FILE" "$TODO_FILE"

# Git-Commit und Push
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"
git add "$TODO_FILE"
git commit -m "removed todos: ${IDS[*]}"
git push