#!/bin/bash

read -p "Storage Box Name: " BOX_NAME
read -p "Storage Box Benutzername (z.B. uXXXXXX): " BOX_USER
read -s -p "Storage Box Passwort: " BOX_PASS
echo ""

if ! command -v rclone &> /dev/null; then
    echo "Fehler: rclone ist nicht installiert oder nicht im PATH."
    exit 1
fi

OBSCURED_PASS=$(rclone obscure "$BOX_PASS")

TMP_DIR=$(mktemp -d)
TMP_PRIV="$TMP_DIR/id_ed25519"
TMP_PUB="$TMP_DIR/id_ed25519.pub"

ssh-keygen -t ed25519 -f "$TMP_PRIV" -N "" -q

HOST="${BOX_USER}.your-storagebox.de"
PORT=23

echo "Übertrage Public Key auf die Storage Box..."
if command -v sshpass &> /dev/null; then
    cat "$TMP_PUB" | sshpass -p "$BOX_PASS" ssh -o StrictHostKeyChecking=no -p "$PORT" "$BOX_USER@$HOST" install-ssh-key
else
    echo "sshpass ist nicht installiert. Bitte das Storage Box Passwort für den SSH-Upload eingeben:"
    cat "$TMP_PUB" | ssh -o StrictHostKeyChecking=no -p "$PORT" "$BOX_USER@$HOST" install-ssh-key
fi

echo "Führe SSH-Verbindungstest durch..."
if ssh -i "$TMP_PRIV" -o StrictHostKeyChecking=no -o BatchMode=yes -p "$PORT" "$BOX_USER@$HOST" "echo 'Test erfolgreich'"; then
    TEST_STATUS="Erfolgreich"
else
    TEST_STATUS="Fehlgeschlagen"
fi

TXT_FILE="${BOX_NAME}.txt"

cat <<EOF > "$TXT_FILE"
Name: $BOX_NAME
Benutzer: $BOX_USER
Host: $HOST
Port: $PORT
Verbindungstest: $TEST_STATUS
Rclone Obscured Passwort: $OBSCURED_PASS

--- PRIVATE KEY ---
$(cat "$TMP_PRIV")

--- PUBLIC KEY ---
$(cat "$TMP_PUB")
EOF

echo -e "\n=== INHALT DER DATEI: $TXT_FILE ===\n"
cat "$TXT_FILE"
echo -e "\n====================================\n"

read -p "Sollen die SSH-Keys in ~/.ssh gespeichert werden? [y/N]: " SAVE_SSH

if [[ "$SAVE_SSH" =~ ^[Yy]$ ]]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    cp "$TMP_PRIV" ~/.ssh/id_ed25519_${BOX_NAME}
    cp "$TMP_PUB" ~/.ssh/id_ed25519_${BOX_NAME}.pub
    chmod 600 ~/.ssh/id_ed25519_${BOX_NAME}
    chmod 644 ~/.ssh/id_ed25519_${BOX_NAME}.pub
    echo "Keys wurden als id_ed25519_${BOX_NAME} in ~/.ssh gespeichert."
fi

rm -rf "$TMP_DIR"
