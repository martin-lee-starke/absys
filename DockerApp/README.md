# Docker Live Container

## Dockerfile

- Es werden die benötigten Packete über apt-get installiert

- Die settings für Apatche und uWSGI werden über die `000-default.conf` und `wsgi.conf` in den Container Kopiert und angewendet.

- der User vagrant wird hinzugefügt (wird im moment nicht verwendet -> Soll später den Webserver ausführen, im moment macht das der root)

- es wird kein virtual environment mehr benötigt 

- die benötigten python pakedges werden über den `wheelhouse` Ordner installiert, inklusive der absys anwendung an sich

- es wird ein angepasstes `install.sh` gestartet, was grundlegende Configurationen vornimmt.

- es sollte der **Port 443** verwendet werden -> dort lausch der Apatche Webserver

- es wird als einstiegsscript das `run.sh` gesetzt und um den Container weiter laufen zu lassen `/bin/bash`

### Docker Image erstellen
Wenn änderungen am Dockerfile oder am Absys System vorgenommen wurden müssen:
- 000-default.conf
- wsgi.conf
- wheelhouse (Ordner)

in den selben Ornder wie das Dockerfile kopiert/angepasst werden. Um das Image dann zu erstellen den Befehl:

```bash
docker build -t absys:1.5 .
docker tag absys:1.5 absys:latest
```

## Docker Container starten

- Wenn der Container gestartet wird sollte er im selben Netz sein wie die in `install.sh` definierte Datenbank!

- Wenn der Container gestaret wird läuft automatisch das `run.sh` Script was checks vornimmt und den apatche2 startet

### Beispiel für das starten eines Absys Containers über die CLI:
```bash
#Container im Netzwerk AbsysNetwork mit dem "interactive" Flag
docker run --network=AbsysNetwork -it absys
```

