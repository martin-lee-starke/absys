postgresql:
  pkg.latest:
    - pkgs:
      - postgresql
  service.running:
    - enable: True
    - watch:
        - file: /etc/postgresql/12/main/pg_hba.conf

/etc/postgresql/12/main/pg_hba.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 644
    - source: salt://postgresql/pg_hba.conf
    - template: jinja
    - require:
      - pkg: postgresql

postgresql-user-django:
  postgres_user.present:
    - name: {{ pillar['db']['username'] }}
    - createdb: True
    - password: {{ pillar['db']['password'] }}
    - user: postgres
    - require:
      - service: postgresql

postgresql-db-django:
  postgres_database.present:
    - name: {{ pillar['db']['name'] }}
    - encoding: UTF8
    - lc_ctype: en_US.UTF-8
    - lc_collate: en_US.UTF-8
    - template: template0
    - owner: {{ pillar['db']['username'] }}
    - user: postgres
    - require:
      - postgres_user: postgresql-user-django
