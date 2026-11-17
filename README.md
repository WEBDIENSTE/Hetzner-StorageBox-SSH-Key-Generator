# Hetzner-StorageBox-SSH-Key-Generator

Das Script loggt sich mit den eingegebenen Daten in der entsprechenden Storagebox ein, nachdem das Passwort mittels rclone obscure verschlüsselt wurde, testet den Login und erzeugt einen Private Key, sowie einen Public Key.

Anschließend können Sie die SSH-Keys im aktuellen Benutzer speichern und verwenden. Da das Script bereits einen erfolgreichen Login und einen Schlüsseltausch durchführte, werden spätere Verbindungen zur Hetzner Storage Box erfolgreich sein, statt aufgrund fehlender Handshakes fehlzuschlagen.

Benutzung / Usage: 
cd ~ && curl -sSL https://raw.githubusercontent.com/WEBDIENSTE/Hetzner-StorageBox-SSH-Key-Generator/refs/heads/main/hetzner-storagebox-ssh-key-generator.sh -o temp-key-gen.sh && bash temp-key-gen.sh && rm temp-key-gen.sh

Entwickelt für Docker-Umgebungen, bspw. für Borg UI, Backrest, BorgBackupServer & Co, für dessen Login zu Hetzner's Storage Boxes ein SSH-Key erforderlich ist.

Das Script wurde entwickelt, speziell um folgenden Fehler zu umgehen:
couldn't connect SSH: ssh: handshake failed: ssh: unable to authenticate, attempted methods [none password], no supported methods remain 
