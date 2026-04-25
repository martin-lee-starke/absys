# AbSYS — Claude Code Guidelines

## Project Context

AbSYS is a **production billing application** used by Saxon educational and social welfare
institutions to calculate and generate invoices for residential care facilities (*Einrichtungen*).
It is actively used in a live environment. Financial calculations are legally significant —
errors have real consequences for public institutions.

The codebase was written by a third party and is maintained by a sysadmin, not its original
author. Code quality is uneven and test coverage is incomplete.

**Stack:** Django 2.2, Python 3.8, PostgreSQL 17
**Language:** German — all model names, field names, variables, and comments are in German.
Keep it that way.
**Dev environment:** `docker compose up` (see `Dev-Infos-neu.md`)
**Tests:** `docker compose exec app make test ENV=docker`
**Linting:** flake8, isort (configured in `setup.cfg`, max line length 99)

---

## Non-Negotiable Rules

### 1. Test suite must be green before any change

```bash
docker compose exec app make test ENV=docker
```

If tests are already failing, document why before proceeding. Never introduce additional
failures.

### 2. Characterization tests before refactoring

Before changing any existing module, write tests that document its **current behavior** —
even if that behavior looks wrong. This captures the implicit contract the rest of the system
depends on. Characterization tests go in `tests/<app>/`.

### 3. Red-Green-Refactor — strictly

1. Write a failing test that describes the desired behavior
2. Make the minimal change to make it pass
3. Only then clean up / refactor

Never write production code that is not justified by a failing test.

### 4. No scope creep

Only change what the task requires. Do not fix adjacent issues, rename unrelated things,
or improve code that is not broken. If you notice something else worth fixing, open a
GitHub issue for it instead.

### 5. Migrations are immutable

Never edit existing migration files. Always create new ones:

```bash
docker compose exec app make makemigrations ENV=docker
```

Every model change must be accompanied by a new migration.

### 6. No destructive database operations without confirmation

Never run `DROP`, `TRUNCATE`, or unqualified `DELETE` without explicit user confirmation.
Before any schema change that touches production, confirm a backup exists.

`USE_TZ = True` is intentionally commented out in `absys/config/settings/common.py` —
do not enable it. There is a known database compatibility issue.

### 7. Deployment safety

- Never `docker push` or restart production containers without explicit instruction
- Never commit secrets or `SECRET_KEY` to the repository (a dummy key exists in
  `common.py` — that is intentional for dev, do not replace it with a real one)
- All environment config goes through `envdir` directories — not hardcoded

### 8. Code style

- **German naming:** model names, field names, variable names, comments stay in German
- Run `flake8 absys/` and `isort --check absys/` after every change — both must pass
- Max line length: 99 characters (configured in `setup.cfg`)
- Do not add English docstrings to existing German modules

---

## Forbidden Without Explicit Approval

These are valid future goals but must not happen as a side effect of unrelated work:

| Action | Reason |
|---|---|
| Django upgrade (2.2 → 4.x) | Major breaking changes; needs dedicated branch and full test coverage first |
| Python version upgrade | Tied to Django upgrade |
| Enable `USE_TZ = True` | Known database compatibility issue |
| Consolidate WeasyPrint + wkhtmltopdf | PDF generation is fragile and minimally tested |
| Split `absys/apps/abrechnung/models.py` | Core billing logic — high risk without characterization tests |

---

## Django Upgrade Path (Preparation Goal)

The medium-term goal is to migrate from Django 2.2 (EOL since June 2022) to Django 4.x
with Python 3.10+. Work on this only in the dedicated `django-upgrade` branch.

**Known incompatibilities to resolve first:**
- `django-extra-views==0.10.0` is pinned to Django 2.x — needs upgrade or replacement
- `django-configurations` version compatibility with Django 4.x unknown
- `WeasyPrint==51` — current API is completely different from 0.5x
- `django-weasyprint==0.5.3` — no longer maintained

**Preparation steps (safe to do on feature branches now):**
1. Expand test coverage across all apps before touching anything
2. Audit deprecated Django 2.x APIs in use (`ugettext`, old-style middleware, etc.)
3. Pin all dependencies to known-compatible versions before the upgrade attempt

---

## Key Files

| File | Purpose |
|---|---|
| `absys/apps/abrechnung/models.py` | Core billing models (630 lines) — highest risk |
| `absys/apps/abrechnung/services.py` | Invoice generation logic |
| `absys/apps/benachrichtigungen/services.py` | Alert/notification engine |
| `absys/apps/einrichtungen/models.py` | Facility management (404 lines) |
| `absys/config/settings/` | Multi-environment settings |
| `tests/conftest.py` | Central pytest fixtures and factories |
| `requirements/docker.pip` | Requirements for the Docker dev container |
| `envs/docker/` | Environment variables for Docker dev |
| `DockerApp/` | Production Docker image (Apache + uWSGI) |

---

## Test Baseline

Run after merging PR #7 (Docker Compose dev environment):

```bash
docker compose exec app make test-fresh ENV=docker
```

Record the result here once captured.
