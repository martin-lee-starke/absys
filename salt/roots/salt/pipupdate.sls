pip-upgrade:
  cmd.run:
    - runas: {{ pillar['project']['user'] }}
    - name: python -m pip install --upgrade pip
    - cwd: /vagrant
    - require:
      - pkg: python-pip