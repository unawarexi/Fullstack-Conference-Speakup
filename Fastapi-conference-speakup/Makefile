# ============================================================================
# SpeakUp AI — Makefile
# ============================================================================

.PHONY: dev prod test lint format docker-up docker-down celery migrate clean

# ── Development ──
dev:
	uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --log-level info

prod:
	gunicorn app.main:app \
		--worker-class uvicorn.workers.UvicornWorker \
		--workers 4 \
		--bind 0.0.0.0:8000 \
		--timeout 120

# ── Celery ──
celery:
	celery -A app.workers.celery_app worker \
		--loglevel=info \
		--concurrency=2 \
		--queues=speakup-ai-default,speakup-ai-summary,speakup-ai-memory,speakup-ai-inference

celery-beat:
	celery -A app.workers.celery_app beat --loglevel=info

# ── Docker ──
docker-up:
	docker compose up -d --build

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f speakup-ai

# ── Database ──
migrate:
	alembic upgrade head

migrate-create:
	alembic revision --autogenerate -m "$(msg)"

migrate-down:
	alembic downgrade -1

# ── Testing ──
test:
	pytest tests/ -v --tb=short

test-cov:
	pytest tests/ -v --cov=app --cov-report=term-missing

test-unit:
	pytest tests/unit/ -v

test-integration:
	pytest tests/integration/ -v

# ── Code Quality ──
lint:
	ruff check app/ infrastructure/ tests/

format:
	ruff format app/ infrastructure/ tests/

typecheck:
	mypy app/

# ── Install ──
install:
	pip install -e ".[dev]"

install-gpu:
	pip install -e ".[dev,gpu]"

# ── Pre-commit ──
hooks-install:
	pre-commit install
	pre-commit install --hook-type commit-msg

hooks-run:
	pre-commit run --all-files

hooks-update:
	pre-commit autoupdate

# ── Security ──
security:
	bandit -r app/ -c pyproject.toml -ll
	pip-audit

# ── CI (compound) ──
ci: lint typecheck test

# ── Clean ──
clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov
