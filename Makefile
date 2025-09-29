PY=python
PIP=pip

.PHONY: dev test lint format docker-up docker-down migrate upgrade seed precommit

dev:
	uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

test:
	cd backend && pytest -q
	cd marafinal && flutter test

lint:
	cd backend && flake8 .
	cd marafinal && flutter analyze

format:
	cd backend && black .
	cd marafinal && dart format .

docker-up:
	docker compose up -d --build

docker-down:
	docker compose down

migrate:
	cd backend && alembic revision --autogenerate -m "auto"

upgrade:
	cd backend && alembic upgrade head

seed:
	$(PY) scripts/seed_data.py

precommit:
	pre-commit run --all-files
