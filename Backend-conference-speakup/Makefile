# ============================================================================
#  SpeakUp Backend — Makefile
#  Runtime: Node.js | DB: PostgreSQL (Prisma) | Cache: Redis | Queue: BullMQ
#  Streaming: Kafka | WebRTC: LiveKit | Billing: Stripe
# ============================================================================

.PHONY: help dev start clean install lint lint-fix test test-run test-watch \
        db-generate db-push db-migrate db-migrate-create db-migrate-reset \
        db-studio db-seed db-status \
        docker-up docker-down docker-rebuild docker-logs docker-ps \
        docker-up-infra docker-clean docker-shell \
        redis-cli redis-flush redis-monitor \
        kafka-init kafka-start kafka-stop kafka-topics kafka-console kafka-status \
        kafka-topics kafka-console \
        k8s-apply k8s-delete k8s-status k8s-logs k8s-port-forward \
        tf-init tf-plan tf-apply tf-destroy \
        build health check-env gen-env \
        logs-tail prisma-format

# ─────────────── CONFIG ───────────────

APP_NAME   := speakup
PORT       := 5000
API_URL    := http://localhost:$(PORT)
K8S_NS     := speakup

# Colors
CYAN    := \033[36m
GREEN   := \033[32m
YELLOW  := \033[33m
RED     := \033[31m
RESET   := \033[0m
BOLD    := \033[1m

# ============================================================================
#  HELP
# ============================================================================

help: ## Show all available commands
	@echo ""
	@echo "$(BOLD)$(CYAN)  SpeakUp Backend — Command Reference$(RESET)"
	@echo "$(CYAN)  ────────────────────────────────────────$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-22s$(RESET) %s\n", $$1, $$2}'
	@echo ""

.DEFAULT_GOAL := help

# ============================================================================
#  DEVELOPMENT
# ============================================================================

install: ## Install all dependencies with npm
	npm install

dev: kafka-start ## Start dev server with hot-reload (node --watch) + Kafka
	npm run dev

start: ## Start production server
	NODE_ENV=production node index.js

clean: ## Remove node_modules, generated files, and caches
	rm -rf node_modules generated .prisma dist .cache
	@echo "$(GREEN)✓ Cleaned$(RESET)"

reinstall: clean install db-generate ## Clean install + regenerate Prisma client

# ============================================================================
#  CODE QUALITY
# ============================================================================

lint: ## Run ESLint on all files
	npx eslint .

lint-fix: ## Run ESLint with auto-fix
	npx eslint . --fix

# ============================================================================
#  TESTING
# ============================================================================

test: ## Run tests in watch mode (vitest)
	npx vitest

test-run: ## Run tests once and exit
	npx vitest run

test-watch: ## Run tests with verbose watch
	npx vitest --reporter verbose

test-coverage: ## Run tests with coverage report
	npx vitest run --coverage

# ============================================================================
#  DATABASE (Prisma + PostgreSQL)
# ============================================================================

db-generate: ## Generate Prisma client from schema
	npx prisma generate

db-push: ## Push schema changes directly (skip migrations — dev only)
	npx prisma db push

db-migrate: ## Run pending migrations
	npx prisma migrate dev

db-migrate-create: ## Create a new migration (usage: make db-migrate-create name=add_feature)
	npx prisma migrate dev --name $(name)

db-migrate-reset: ## Reset database and replay all migrations (destructive)
	npx prisma migrate reset

db-migrate-deploy: ## Deploy migrations in production (non-interactive)
	npx prisma migrate deploy

db-migrate-status: ## Show migration status
	npx prisma migrate status

db-studio: ## Open Prisma Studio GUI
	npx prisma studio

db-seed: ## Run database seed script
	node prisma/seed.js

db-status: ## Validate schema and check DB connection
	npx prisma validate && npx prisma migrate status

prisma-format: ## Format the Prisma schema file
	npx prisma format

# ============================================================================
#  DOCKER COMPOSE
# ============================================================================

docker-up: ## Start all services (app + infra) in detached mode
	docker compose up -d

docker-up-infra: ## Start only Docker infrastructure (postgres, redis, livekit, mailhog)
	docker compose up -d postgres redis livekit mailhog

docker-down: ## Stop all running services
	docker compose down

docker-rebuild: ## Rebuild and restart app container
	docker compose up -d --build app

docker-logs: ## Tail logs from all containers
	docker compose logs -f --tail=100

docker-logs-app: ## Tail logs from app container only
	docker compose logs -f --tail=100 app

docker-logs-db: ## Tail logs from postgres container
	docker compose logs -f --tail=50 postgres

docker-ps: ## List running containers with status
	docker compose ps

docker-shell: ## Open a shell inside the running app container
	docker compose exec app sh

docker-clean: ## Stop everything, remove volumes (destructive)
	docker compose down -v --remove-orphans
	@echo "$(YELLOW)⚠ Volumes removed — data is gone$(RESET)"

docker-restart: docker-down docker-up ## Restart all services

# ============================================================================
#  REDIS
# ============================================================================

redis-cli: ## Open Redis CLI connected to local instance
	docker compose exec redis redis-cli

redis-flush: ## Flush all Redis data (destructive)
	docker compose exec redis redis-cli FLUSHALL
	@echo "$(YELLOW)⚠ Redis flushed$(RESET)"

redis-monitor: ## Watch all Redis commands in real time
	docker compose exec redis redis-cli MONITOR

redis-info: ## Show Redis server info and memory usage
	docker compose exec redis redis-cli INFO memory | head -20

redis-keys: ## List all keys in Redis (dev only)
	docker compose exec redis redis-cli KEYS '*'

# ============================================================================
#  KAFKA (4.2.0 KRaft — no Zookeeper)
#  Local: Kafka installed at /usr/local/kafka (on PATH via .zshrc)
#  Production: Set KAFKA_BROKERS, KAFKA_SSL, KAFKA_SASL_* in .env
# ============================================================================

KAFKA_CONFIG     := /usr/local/kafka/config/server.properties
KAFKA_LOG_DIR    := /tmp/kraft-combined-logs
KAFKA_STORAGE    := kafka-storage.sh
KAFKA_SERVER     := kafka-server-start.sh
KAFKA_SERVER_STOP:= kafka-server-stop.sh
KAFKA_TOPICS_CMD := kafka-topics.sh
KAFKA_CONSOLE_CMD:= kafka-console-consumer.sh
KAFKA_BOOTSTRAP  := localhost:9092

SPEAKUP_TOPICS := speakup.meeting.events speakup.participant.events speakup.chat.messages \
	speakup.recording.events speakup.notification.events speakup.analytics.events \
	speakup.user.events speakup.ai.transcription speakup.ai.live_insights \
	speakup.ai.emotion_signals speakup.ai.coaching_hints speakup.ai.copilot_suggestions \
	speakup.ai.meeting_summary speakup.ai.action_items speakup.ai.memory_updates \
	speakup.ai.cv_analysis speakup.media.audio_chunks speakup.media.video_frames

kafka-init: ## Format KRaft storage (run once on first setup)
	@echo "$(CYAN)Generating cluster UUID and formatting KRaft storage...$(RESET)"
	$(eval CLUSTER_ID := $(shell $(KAFKA_STORAGE) random-uuid))
	$(KAFKA_STORAGE) format -t $(CLUSTER_ID) --standalone -c $(KAFKA_CONFIG)
	@echo "$(GREEN)✓ KRaft storage formatted with cluster ID: $(CLUSTER_ID)$(RESET)"

kafka-start: ## Start Kafka broker (KRaft mode, background)
	@if lsof -i :9092 -sTCP:LISTEN -t >/dev/null 2>&1; then \
		echo "$(YELLOW)⚠ Kafka already running on port 9092$(RESET)"; \
	else \
		echo "$(CYAN)Starting Kafka (KRaft mode)...$(RESET)"; \
		$(KAFKA_SERVER) -daemon $(KAFKA_CONFIG); \
		TRIES=0; \
		while [ $$TRIES -lt 12 ]; do \
			sleep 2; \
			TRIES=$$((TRIES + 1)); \
			if lsof -i :9092 -sTCP:LISTEN -t >/dev/null 2>&1; then \
				echo "$(GREEN)✓ Kafka running on $(KAFKA_BOOTSTRAP) (took $$((TRIES * 2))s)$(RESET)"; \
				break; \
			fi; \
			echo "$(YELLOW)  waiting for Kafka... ($$((TRIES * 2))s)$(RESET)"; \
		done; \
		if ! lsof -i :9092 -sTCP:LISTEN -t >/dev/null 2>&1; then \
			echo "$(RED)✗ Kafka failed to start after 24s — check logs: $(KAFKA_LOG_DIR)/server.log$(RESET)"; \
		fi \
	fi

kafka-stop: ## Stop Kafka broker
	@echo "$(CYAN)Stopping Kafka...$(RESET)"
	$(KAFKA_SERVER_STOP) || true
	@echo "$(GREEN)✓ Kafka stopped$(RESET)"

kafka-restart: kafka-stop kafka-start ## Restart Kafka broker

kafka-status: ## Check if Kafka is running
	@if lsof -i :9092 -sTCP:LISTEN -t >/dev/null 2>&1; then \
		echo "$(GREEN)✓ Kafka is running on port 9092$(RESET)"; \
	else \
		echo "$(RED)✗ Kafka is not running$(RESET)"; \
	fi

kafka-logs: ## Tail Kafka server logs
	tail -f $(KAFKA_LOG_DIR)/server.log

kafka-topics: ## List all Kafka topics
	$(KAFKA_TOPICS_CMD) --bootstrap-server $(KAFKA_BOOTSTRAP) --list

kafka-create-topics: ## Create all SpeakUp Kafka topics
	@for topic in $(SPEAKUP_TOPICS); do \
		$(KAFKA_TOPICS_CMD) --bootstrap-server $(KAFKA_BOOTSTRAP) \
			--create --topic $$topic --partitions 3 --replication-factor 1 --if-not-exists; \
	done
	@echo "$(GREEN)✓ All topics created$(RESET)"

kafka-describe: ## Describe a Kafka topic (usage: make kafka-describe topic=speakup.meeting.events)
	$(KAFKA_TOPICS_CMD) --bootstrap-server $(KAFKA_BOOTSTRAP) --describe --topic $(topic)

kafka-console: ## Consume messages from a topic (usage: make kafka-console topic=speakup.meeting.events)
	$(KAFKA_CONSOLE_CMD) --bootstrap-server $(KAFKA_BOOTSTRAP) --topic $(topic) --from-beginning

kafka-clean: ## Delete KRaft storage and logs (destructive — requires kafka-init again)
	@echo "$(YELLOW)⚠ Removing Kafka storage at $(KAFKA_LOG_DIR)$(RESET)"
	rm -rf $(KAFKA_LOG_DIR)
	@echo "$(GREEN)✓ Kafka storage cleaned — run 'make kafka-init' before next start$(RESET)"

kafka-setup: kafka-init kafka-start kafka-create-topics ## One-liner: init + start + create topics (first time)

# ============================================================================
#  KUBERNETES
# ============================================================================

k8s-apply: ## Apply all K8s manifests to cluster
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/secrets.yaml
	kubectl apply -f k8s/deployment.yaml
	kubectl apply -f k8s/service.yaml

k8s-delete: ## Delete all K8s resources in the namespace
	kubectl delete -f k8s/ --ignore-not-found

k8s-status: ## Show pods, services, and deployments in namespace
	@echo "$(CYAN)── Pods ──$(RESET)"
	kubectl get pods -n $(K8S_NS)
	@echo "\n$(CYAN)── Services ──$(RESET)"
	kubectl get svc -n $(K8S_NS)
	@echo "\n$(CYAN)── Deployments ──$(RESET)"
	kubectl get deploy -n $(K8S_NS)

k8s-logs: ## Tail logs from the app deployment
	kubectl logs -f -n $(K8S_NS) -l app=$(APP_NAME) --tail=100

k8s-port-forward: ## Forward local port to K8s service (localhost:5000)
	kubectl port-forward -n $(K8S_NS) svc/$(APP_NAME) $(PORT):$(PORT)

k8s-restart: ## Restart the deployment (rolling)
	kubectl rollout restart deployment/$(APP_NAME) -n $(K8S_NS)

k8s-rollout-status: ## Watch rollout status
	kubectl rollout status deployment/$(APP_NAME) -n $(K8S_NS)

k8s-describe: ## Describe pods for debugging
	kubectl describe pods -n $(K8S_NS) -l app=$(APP_NAME)

k8s-exec: ## Open a shell in the running K8s pod
	kubectl exec -it -n $(K8S_NS) $$(kubectl get pod -n $(K8S_NS) -l app=$(APP_NAME) -o jsonpath='{.items[0].metadata.name}') -- sh

# ============================================================================
#  TERRAFORM
# ============================================================================

tf-init: ## Initialize Terraform working directory
	cd terraform && terraform init

tf-plan: ## Preview infrastructure changes
	cd terraform && terraform plan

tf-apply: ## Apply infrastructure changes
	cd terraform && terraform apply

tf-destroy: ## Destroy all managed infrastructure (destructive)
	cd terraform && terraform destroy

tf-output: ## Show Terraform outputs
	cd terraform && terraform output

tf-fmt: ## Format Terraform files
	cd terraform && terraform fmt -recursive

tf-validate: ## Validate Terraform configuration
	cd terraform && terraform validate

# ============================================================================
#  HEALTH & DIAGNOSTICS
# ============================================================================

health: ## Hit the health endpoint
	@curl -sf $(API_URL)/health | node -e "process.stdin.on('data',d=>console.log(JSON.stringify(JSON.parse(d),null,2)))" 2>/dev/null || echo "$(RED)✗ Server not reachable at $(API_URL)$(RESET)"

health-ready: ## Check readiness probe
	@curl -sf $(API_URL)/health/ready | node -e "process.stdin.on('data',d=>console.log(JSON.stringify(JSON.parse(d),null,2)))" 2>/dev/null || echo "$(RED)✗ Not ready$(RESET)"

health-detailed: ## Full health check with all service statuses
	@curl -sf $(API_URL)/health/detailed | node -e "process.stdin.on('data',d=>console.log(JSON.stringify(JSON.parse(d),null,2)))" 2>/dev/null || echo "$(RED)✗ Not reachable$(RESET)"

metrics: ## Fetch Prometheus metrics
	@curl -sf $(API_URL)/metrics | head -40

api-info: ## Show API version and available endpoints
	@curl -sf $(API_URL)/api/v1 | node -e "process.stdin.on('data',d=>console.log(JSON.stringify(JSON.parse(d),null,2)))" 2>/dev/null || echo "$(RED)✗ Not reachable$(RESET)"

# ============================================================================
#  ENVIRONMENT
# ============================================================================

check-env: ## Validate required environment variables are set
	@echo "$(CYAN)Checking environment variables...$(RESET)"
	@test -f .env && echo "$(GREEN)✓ .env file found$(RESET)" || echo "$(RED)✗ .env file missing$(RESET)"
	@test -n "$$DATABASE_URL" && echo "$(GREEN)✓ DATABASE_URL$(RESET)" || (grep -q DATABASE_URL .env 2>/dev/null && echo "$(GREEN)✓ DATABASE_URL (in .env)$(RESET)" || echo "$(YELLOW)⚠ DATABASE_URL not set$(RESET)")
	@test -n "$$REDIS_URL" && echo "$(GREEN)✓ REDIS_URL$(RESET)" || (grep -q REDIS_URL .env 2>/dev/null && echo "$(GREEN)✓ REDIS_URL (in .env)$(RESET)" || echo "$(YELLOW)⚠ REDIS_URL not set$(RESET)")

gen-env: ## Generate .env from .env.example (won't overwrite existing)
	@test -f .env && echo "$(YELLOW)⚠ .env already exists — skipping$(RESET)" || (cp .env.example .env && echo "$(GREEN)✓ .env created from .env.example$(RESET)")

# ============================================================================
#  BUILD & DEPLOY
# ============================================================================

build: ## Build production Docker image
	docker build -t $(APP_NAME)-api:latest .

build-no-cache: ## Build Docker image without cache
	docker build --no-cache -t $(APP_NAME)-api:latest .

docker-tag: ## Tag image for registry (usage: make docker-tag registry=ghcr.io/user)
	docker tag $(APP_NAME)-api:latest $(registry)/$(APP_NAME)-api:latest

docker-push: ## Push image to registry (usage: make docker-push registry=ghcr.io/user)
	docker push $(registry)/$(APP_NAME)-api:latest

# ============================================================================
#  LOGS & MONITORING
# ============================================================================

logs-tail: ## Tail application logs in dev (most recent)
	@tail -f logs/*.log 2>/dev/null || echo "$(YELLOW)No log files found — start the server first$(RESET)"

# ============================================================================
#  COMPOUND / WORKFLOW COMMANDS
# ============================================================================

setup: install db-generate ## First-time project setup (install + generate)
	@echo "$(GREEN)✓ Project setup complete. Run 'make dev' to start.$(RESET)"

infra: docker-up-infra kafka-start ## Alias: start all infrastructure (Docker + Kafka)
	@echo "$(GREEN)✓ Infrastructure ready (postgres, redis, livekit, mailhog, kafka)$(RESET)"

fresh: docker-up-infra kafka-start db-migrate-reset db-generate ## Fresh start: infra + Kafka + reset DB + regenerate
	@echo "$(GREEN)✓ Fresh environment ready$(RESET)"

deploy-k8s: build k8s-apply ## Build image and deploy to K8s
	@echo "$(GREEN)✓ Deployed to Kubernetes$(RESET)"

ci: lint test-run ## CI pipeline: lint + test
	@echo "$(GREEN)✓ CI checks passed$(RESET)"

nuke: docker-clean clean ## Nuclear option: remove everything (containers, volumes, node_modules)
	@echo "$(RED)✗ Everything destroyed. Run 'make setup' to rebuild.$(RESET)"
