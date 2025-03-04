# Docker Live Container

## Dockerfile

- Es werden die benötigten Pakete über apt-get installiert

- Die Settings für Apatche und uWSGI werden über die `000-default.conf` und `wsgi.conf` in den Container kopiert und angewendet.

- der User vagrant wird hinzugefügt

- es wird kein virtual Environment mehr benötigt 

- die benötigten python pakedges werden über den `wheelhouse` Ordner installiert, inklusive der absys anwendung an sich

- es wird ein angepasstes `install.sh` gestartet, was grundlegende Configurationen vornimmt.

- es sollte der **Port 443** verwendet werden -> dort lauscht der Apache Webserver

- es wird als Einstiegsscript das `run.sh` gesetzt und um den Container weiter laufen zu lassen `/bin/bash`

### Docker Image erstellen
Wenn Änderungen am Dockerfile oder am Absys System vorgenommen wurden, müssen:
- 000-default.conf
- wsgi.conf
- wheelhouse (Ordner)

in denselben Ordner wie das Dockerfile kopiert/angepasst werden. Um das Image dann zu erstellen, den Befehl:

```bash
docker build -t absys:1.5 .
docker tag absys:1.5 absys:latest
```

um das Docker Image ohne Repository zu portieren, muss es in eine .tar Datei gewandelt werden

```bash
#wandelt das image in eine .tar -> die dann gezippt wird
docker save absys:1.5.2 | gzip > absys152.tar.gz
```

## Docker Container starten

- Wenn der Container gestartet wird, sollte er im selben Netz sein wie die in `install.sh` definierte Datenbank!

- Wenn der Container gestartet wird, läuft automatisch das `run.sh` Script, was Checks vornimmt und den apatche2 startet.

### Beispiel für das Starten eines Absys Containers über die CLI:
```bash
#Container im Netzwerk AbsysNetwork mit dem "interactive" Flag
docker run -it --env DJANGO_ALLOWED_HOSTS=172.19.0.5 --env DEFAULT_DATABASE_URL=postgres://absys:absys@875128a60a85/absys --network=AbsysNetwork absys:1.5.2 
```


