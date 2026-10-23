# Update

<!-- Vorlage: docs/UPDATE.md – Anweisung 01. <projekt>, <PROJEKT> und Pfade anpassen. -->

Die VM läuft auf `<PROJEKT>_VERSION=latest` und dem Branch `stabil`. Ein neues Release
holst du so (`~/<projekt>` ist der Ordner mit dem Klon). **Vorher die Release-Notiz lesen**
(`docs/releases/vX.Y.Z.md`): Steht dort ein einmaliger Schritt, kommt er nach dem Update dran.

```bash
cd ~/<projekt> && git pull && cd deploy \
  && sudo docker compose pull \
  && sudo docker compose up -d --remove-orphans
```

Danach prüfen:

```bash
sudo docker compose ps                          # alle Dienste „running“/„healthy“
sudo docker compose logs migrate | tail -n 5    # Migrationen fertig, Sicherung angelegt
```

Die Versionsnummer steht unten in der App. Danach die Kernabläufe aus der Release-Notiz
einmal durchklicken und 15 Minuten lang Logs (`sudo docker compose logs -f --since 15m`)
und die Statusseite beobachten.

**Sofort zurück auf die alte Version** (siehe unten), wenn `migrate` scheitert, ein Dienst
nicht `healthy` wird, die Anmeldung oder ein Kernablauf nicht geht oder neue Fehler
wiederholt im Log stehen. Erst zurück, dann Ursache suchen.

## Erstmalig einrichten

```bash
git clone --branch stabil https://github.com/Bamberger-IT-Services/<repo>.git ~/<projekt>
sudo install -d -m 700 /etc/<projekt>
sudo cp ~/<projekt>/deploy/.env.example /etc/<projekt>/deploy.env
sudo chmod 600 /etc/<projekt>/deploy.env       # Werte eintragen, Geheimnisse erzeugen
ln -s /etc/<projekt>/deploy.env ~/<projekt>/deploy/.env
# Nur bei privaten Images: einmalig bei GHCR anmelden (Token nur mit read:packages)
sudo docker login ghcr.io -u <github-benutzer>
```

## Zurück auf eine ältere Version

```bash
ALT=1.2.0
sudo sed -i "s/^<PROJEKT>_VERSION=.*/<PROJEKT>_VERSION=$ALT/" /etc/<projekt>/deploy.env
cd ~/<projekt> && git fetch --tags && git checkout "v$ALT" && cd deploy \
  && sudo docker compose pull && sudo docker compose up -d --remove-orphans
```

Hat das neuere Release die Datenbank migriert, vorher die Sicherung aus dem Migrationslauf
zurückspielen (siehe `docs/` › Sicherung). Zurück auf `latest`: `<PROJEKT>_VERSION=latest`
eintragen und `git checkout stabil`.
