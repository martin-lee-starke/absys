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



