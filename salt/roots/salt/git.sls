git:
  pkg.latest

git-flow:
  pkg.latest

git-flow-init:
  cmd.run:
    - name: git flow init -d
    - runas: {{ pillar['project']['user'] }}
    - cwd: /vagrant
    - unless: grep "^\[gitflow" /vagrant/.git/config >/dev/null
    - require:
      - pkg: git-flow

tig:
  pkg.latest

git-push-default:
  git.config_set:
    - name: push.default
    - value: simple
    - user: {{ pillar['project']['user'] }}
    - global: True
