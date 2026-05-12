# Deployment-Anleitung — AbSYS v1.6.3+

## Neu ab v1.6.3: Pflicht-Umgebungsvariablen

Der Container startet **nicht** ohne diese zwei neuen Variablen in der `docker-compose.yml`:

```yaml
environment:
  - DJANGO_SECRET_KEY=<langer_zufälliger_schlüssel>
  - DJANGO_EMAIL_HOST_PASSWORD=<smtp_passwort>
```

Einen sicheren Secret Key erzeugen:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(50))"
```

---

## Ablauf

### 1. Backup sicherstellen

Vor jedem Update prüfen, dass ein aktuelles Backup vorhanden ist
(pgbackup-Container läuft und hat heute gesichert).

### 2. Compose-File aktualisieren

Image-Tag auf die neue Version setzen und die zwei Pflicht-Variablen ergänzen falls noch nicht vorhanden:

```yaml
image: 'absys:1.6.3'
environment:
  - DJANGO_ALLOWED_HOSTS=...
  - DEFAULT_DATABASE_URL=...
  - DJANGO_SECRET_KEY=...
  - DJANGO_EMAIL_HOST_PASSWORD=...
```

### 3. Migrationen prüfen

```bash
# Erst anschauen — läuft keine Migration durch, kann dieser Schritt entfallen
docker compose run --rm absys-app envdir /var/envdir/absys manage.py migrate --plan

# Wenn Migrationen anstehen: ausführen
docker compose run --rm absys-app envdir /var/envdir/absys manage.py migrate
```

### 4. Container neu starten

```bash
docker compose pull
docker compose up -d
```

### 5. Prüfen

```bash
# Logs beobachten — "Installation abgeschlossen" muss erscheinen
docker compose logs -f absys-app

# HTTP-Status prüfen
curl -k -o /dev/null -w "%{http_code}" https://<hostname>/login/
# Erwarteter Wert: 200
```

---

## Rollback

```bash
# Image-Tag im Compose-File auf die vorherige Version zurücksetzen, dann:
docker compose up -d
```

Datenbank-Rollback ist nur bei Migrationen nötig — vorher das Backup einspielen.
