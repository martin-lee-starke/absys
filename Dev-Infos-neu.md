# I Anlegen der Dev-Umgebung mit Vagrant

## Voraussetzungen
- Docker oder VirtualBox als Provider
- wenn die DEV-Umgebung gebaut wird, muss die deploymant box im vagrant-File auskommentiert werden!
## 1. Starten der Vagrant Box
### 1.1 vagrant up - Befehl im Terminal absetzten
### 1.2 vagrant ssh - um sich auf die Box zu verbinden
dann folgende Befehle ausführen:
```bash
cd /vagrant/ 
make develop
make runserver
```
Die Dev-Datenbank läuft auf einem extra Container, die muss die Box erreichen können und der connection string muss in `absys/config/settings/databases.py` eingetragen werden.

### 1.3 es kann entwickelt werden!
Änderungen an Dateien werden direkt in die Vagrant Box übernommen. Der make develop Befehl ruft die installation der "benötigten" Bibliotheken auf die in dem Ordner `requirements\` angegeben sind.

Bei Änderungen von Python Bibliotheken müssen diese **dort** angepasst werden.

# II Docker Container für Deployment erzeugen
Um den Docker Container zu erstellen müssen folgende Schritte erfolgen
1. Setup-Paket in Dev-Box erstellen
2. Deployment Umgebung erstellen (Nur die App + Apache und uWSGI)
3. Setup einmal ausführen
4. Testen ob alles geht wie gewünscht
5. Export des Wheelhouse für den Container
6. Container erstellen

## 1. Setup-Paket erstellen
Das Setup-Paket wird für Installation/Upgrade der Staging- und Production- Server benötigt.

Um die Deployment Vagrant Box zu benutzen, muss vorher das absys Paket innerhalb der dev Vagrant Box erstellt werden. Außerdem müssen alle Python Wheels, die auf dem Server installiert werden sollen, erstellt und gesammelt werden. Dazu wie folgt vorgehen:

```bash
(pyvenv) vagrant@absys-dev:/vagrant$ make dist
(pyvenv) vagrant@absys-dev:/vagrant$ make wheelhouse
```

## 2. Deployment Umgebung erstellen
Um die Deployment Umgebung zu erstellen muss die deploymentD Vagrant Box im Vagrant File einkommentiert und die DevD Box auskommentiert werden.
```
config.vm.define "deploymentD", autostart: false do |deployment|
	config.vm.hostname = "absys-deployment"
	
	# Port forwarding for Apache server.
	config.vm.network "forwarded_port", guest: 443, host: 8080,
		auto_correct: true
	config.vm.network "forwarded_port", guest: 80, host: 8081,
		auto_correct: true
end
```

Dann `vagrant up deploymentD --provider=docker --provision` um die Box zu starten.

## 3. Setup auf deploymentD ausführen
1. `vagrant ssh deploymentD`
2. mit der Test DB ins selbe Netz
	`docker network connect absys-master_default ee3515b9fefc9503d3df8f7c81a303664a9519ff6974111a03af09f3c007a6a2`

3. Workauound ABSYS 3.7:
```bash
source pyvenv/bin/activate
python -m pip install --upgrade pip
#Pongo Dependency Error -> Weasyprint mal auf neuen Stand heben
sudo apt-get install libpangocairo-1.0-0

sudo locale-gen en_US.UTF-8 
#make restartdb
#cd /vagrant/
#make startdb
#make create-db-user
#make create-db
```
3. Setup ausführen `/vagrant/setup/install.sh`

## 4. Testen
Die Staging version von AbSys wird im deployment Container mit Apache und uWSGI gehostet. Nun müssen alle neuen Funktionalitäten geprüft werden!

Die Seite ist unter `https://127.0.0.1:8080/` erreichbar.

> ggf. [[#Temporäre Workarounds für python3.6]] beachten. (nur bei Versionen <1.5)
## 5. Wheelhouse kopieren
 Wenn alles wie gewünscht funktioniert hat, dann einfach den erzeugten Ordner `wheelhouse` in den Ordner `DockerApp` kopieren.

### 6. Container bauen
in den Ordner für die DockerApp gehen! `cd cd DockerApp/`
 **Docker Commands:**
```yaml
# Docker Container auf dem Ordner bauen
# -t ist der Name des Images:Versionsnummer
docker build -t absys:1.5.6 .

#Starten eines neunen Containers mit dem eben erstellten Image
# Die --env sind für die allowed hosts und die Datenbank
docker run -it --env DJANGO_ALLOWED_HOSTS=172.19.0.3 --env DEFAULT_DATABASE_URL=postgres://absys:absys@875128a60a85/absys --network=AbsysNetwork absys:1.5.6

#Fügt den Container in ein Docker Netzwerk ein
#muss ins selbe netzt wie die DB!
docker network connect AbsysNetwork absys

#Sichert das erstellte Image in ein zip File für export
docker save absys:1.5.6 | gzip > absys156.tar.gz

# ggf. kann das Image mit dem latest Flag markiert werden
docker tag absys:1.5.6 absys:latest
```


# Anmerkungen für das Entwickeln

## Python3 Version
Die Application(<V1.5) läuft in der Python Version 3.6! Einige der genutzten Python Pakete kommen aber mit einer neuern Version nicht klar. Wenn die Version geändert werden sollte, müssen ggf. auch nicht mehr kompatible Pakete geändert werden.

### ändern der Python Version
Wenn die Python3 Version geändert werden soll, müssen folgende Änderungen erfolgen:
##### python installation mit Salt
in `salt/roots/salt/python3.sls` muss python installiert werden. Wenn es eine ältere version ist muss ggf. für die apt installation noch das passende repository hinzugefügt werden.
```
python3:

cmd.run:

- name: sudo add-apt-repository ppa:deadsnakes/ppa && sudo apt-get update

- runas: {{ pillar['project']['user'] }}

pkg.installed:

- pkgs:

- python3.6

- python3.6-dev

- python3-pip

- python3.6-venv
```

und

in `salt/roots/salt/pyvenv.sls` muss die gewünschte Python version für das Environment angegeben werden.
##### python version in apatche.conf
in `salt/roots/salt/apache/000-default.conf` muss die verwendete Python3 version eingetragen werden.

```yaml
# WSGI
        WSGIDaemonProcess absys.example.com python-path={{ salt['pillar.get']('project:home', '/home/vagrant') }}/pyvenv/lib/python3.6/site-packages processes=2 threads=15 display-name=%{GROUP} lang='en_US.UTF-8' locale='en_US.UTF-8'
        WSGIProcessGroup absys.example.com
        WSGIScriptAlias / {{ salt['pillar.get']('project:home', '/home/vagrant') }}/pyvenv/lib/python3.6/site-packages/absys/config/wsgi.py

        <Directory {{ salt['pillar.get']('project:home', '/home/vagrant') }}/pyvenv/lib/python3.6/site-packages/absys/config>
            <Files wsgi.py>
                AllowOverride None
                Require all granted
            </Files>
        </Directory>
    </VirtualHost>
```


## Zusätzliche Infos
#### Pakete die Probleme machen:
- django-extra-views -> ist in der Version 0.10.0 installiert und benötigt python3.6

#### Temporäre Workarounds für python3.6:
 
``` bash
source pyvenv/bin/activate
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1
sudo python -m pip install --upgrade pip
sudo apt-get install libpangocairo-1.0-0
sudo pip3.6 install pyyaml
#apache2-dev wird für die erzeugung der wsgu version gebraucht
pip install mod-wsgi
mod_wsgi-express module-config 
```
	`LoadModule wsgi_module "/home/vagrant/pyvenv/lib/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so" WSGIPythonHome "/home/vagrant/pyvenv"`

Der Pfad `/home/vagrant/pyvenv/lib/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so` muss in der Datei `/etc/apatche2/modes-enabled/wsgi.load` als Pfad zur richtigen Python version eingetragen werden. **Für die jeweilige python Version muss das Richtige wsgi Modul eingestellt werden!!!**

Bsp.: (Python3.6 wsgi Modul)
```
LoadModule wsgi_module /home/vagrant/pyvenv/lib/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so
```



