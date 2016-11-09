general-pkgs:
  pkg.installed:
    - pkgs:
      - build-essential: 12.1ubuntu2
      - gettext: 0.19.7-2ubuntu3

postgresql-pkgs:
  pkg.installed:
    - pkgs:
      - libpq-dev: 9.5.5-0ubuntu0.16.04

lxml-pkgs:
  pkg.installed:
    - pkgs:
      - libxslt1-dev: 1.1.28-2.1

pillow-pkgs:
  pkg.installed:
    - pkgs:
      - libtiff5-dev: 4.0.6-1
      - libjpeg-dev: 8c-2ubuntu8
      - zlib1g-dev: 1:1.2.8.dfsg-2ubuntu4
      - libfreetype6-dev: 2.6.1-0.1ubuntu2
      - liblcms2-dev: 2.6-3ubuntu2
      - libwebp-dev: 0.4.4-1
