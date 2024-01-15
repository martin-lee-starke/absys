  switchPython:
    cmd.run:
    - name: sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && sudo update-alternatives --config python3
    - runas: {{ pillar['project']['user'] }}
    - require:
      - sls: python3