apache2:
  pkg.latest:
    - pkgs:
      - apache2
    - require:
      - sls: switchPython
  service.running:
    - enable: True
    - watch:
      - file: /etc/apache2/conf-available/wsgi.conf
      - file: /etc/apache2/sites-available/000-default.conf

#enable-ssl-module:
  #apache_module.enable:
    #- name: ssl
    #- require:
      #- pkg: apache2

#enable-headers-module:
  #apache_module.enable:
    #- name: headers
    #- require:
      #- pkg: apache2

enable-ssl-module:
  cmd.run:
    - unless: stat /etc/apache2/mods-enabled/ssl.load
    - name: a2enmod ssl
    - require:
      - pkg: apache2

enable-headers-module:
  cmd.run:
    - unless: stat /etc/apache2/mods-enabled/headers.load
    - name: a2enmod headers
    - require:
      - pkg: apache2

libapache2-mod-wsgi-py3:
  pkg.latest:
    - pkgs:
      - apache2-dev
      - libapache2-mod-wsgi-py3
      - mc
    - require:
      - pkg: apache2

/etc/apache2/conf-available/wsgi.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://apache/wsgi.conf
    - require:
      - pkg: libapache2-mod-wsgi-py3
  apache_conf.enabled:
    - name: wsgi

/etc/apache2/sites-available/000-default.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://apache/000-default.conf
    - template: jinja
    - require:
      - pkg: libapache2-mod-wsgi-py3
  apache_site.enabled:
    - name: 000-default

media-directory:
  file.directory:
    - name: {{ salt['pillar.get']('project:home', '/home/vagrant') }}/media
    - user: {{ pillar['project']['user'] }}
    - group: {{ pillar['project']['user'] }}
    - mode: 755

static_root-directory:
  file.directory:
    - name: {{ salt['pillar.get']('project:home', '/home/vagrant') }}/static_root
    - user: {{ pillar['project']['user'] }}
    - group: {{ pillar['project']['user'] }}
    - mode: 755
