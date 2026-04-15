# ============================================================================
# SpeakUp Flutter — Makefile
# Usage: make <target>
# ============================================================================

.PHONY: help clean reset get upgrade outdated build-runner \
        run run-release run-profile \
        build-apk build-appbundle build-ipa build-web build-macos build-windows build-linux \
        analyze format fix test test-coverage integration-test \
        icons splash env firebase-init gen loc \
        doctor devices logs install-apk 

# ─── Defaults ────────────────────────────────────────────────────────────────
DART  := dart
FLUTTER := flutter

# ─── Help ────────────────────────────────────────────────────────────────────
help: ## Show all available targets
	@echo ""
	@echo "  SpeakUp Flutter — Available Commands"
	@echo "  ════════════════════════════════════════"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ─── Setup & Dependencies ───────────────────────────────────────────────────
get: ## Get all dependencies
	$(FLUTTER) pub get

upgrade: ## Upgrade dependencies to latest compatible versions
	$(FLUTTER) pub upgrade

outdated: ## Show outdated dependencies
	$(FLUTTER) pub outdated

env: ## Copy .env.example to .env (if not exists)
	@[ -f .env ] && echo ".env already exists" || (cp .env.example .env && echo "Created .env from .env.example")

# ─── Clean & Reset ──────────────────────────────────────────────────────────
clean: ## Clean build artifacts
	$(FLUTTER) clean

reset: clean get ## Full reset: clean + get dependencies
	@echo "✓ Reset complete"

nuke: ## Nuclear reset: remove all caches, locks, and rebuild
	$(FLUTTER) clean
	rm -rf .dart_tool .flutter-plugins .flutter-plugins-dependencies
	rm -rf build ios/Pods ios/Podfile.lock macos/Pods macos/Podfile.lock
	rm -rf pubspec.lock
	$(FLUTTER) pub get
	@[ -d ios ] && cd ios && pod install --repo-update && cd .. || true
	@[ -d macos ] && cd macos && pod install --repo-update && cd .. || true
	@echo "✓ Nuclear reset complete"

# ─── Code Generation ────────────────────────────────────────────────────────
build-runner: ## Run build_runner (one-shot)
	$(DART) run build_runner build --delete-conflicting-outputs

watch: ## Run build_runner in watch mode
	$(DART) run build_runner watch --delete-conflicting-outputs

gen: build-runner ## Alias for build-runner

icons: ## Generate app launcher icons
	$(DART) run flutter_launcher_icons

splash: ## Generate native splash screen
	$(DART) run flutter_native_splash:create

# ─── Run ─────────────────────────────────────────────────────────────────────
run: ## Run app in debug mode
	$(FLUTTER) run

run-release: ## Run app in release mode
	$(FLUTTER) run --release

run-profile: ## Run app in profile mode
	$(FLUTTER) run --profile

run-web: ## Run app on Chrome
	$(FLUTTER) run -d chrome

run-macos: ## Run app on macOS
	$(FLUTTER) run -d macos

run-windows: ## Run app on Windows
	$(FLUTTER) run -d windows

# ─── Build ───────────────────────────────────────────────────────────────────
build-apk: ## Build Android APK (release)
	$(FLUTTER) build apk --release

build-apk-split: ## Build Android APKs split per ABI
	$(FLUTTER) build apk --release --split-per-abi

build-appbundle: ## Build Android App Bundle (release)
	$(FLUTTER) build appbundle --release

build-ipa: ## Build iOS IPA (release)
	$(FLUTTER) build ipa --release

build-web: ## Build web app (release)
	$(FLUTTER) build web --release

build-macos: ## Build macOS app (release)
	$(FLUTTER) build macos --release

build-windows: ## Build Windows app (release)
	$(FLUTTER) build windows --release

build-linux: ## Build Linux app (release)
	$(FLUTTER) build linux --release

build-all: build-apk build-appbundle build-web ## Build APK + AAB + Web

# ─── Quality & Analysis ──────────────────────────────────────────────────────
analyze: ## Run static analysis
	$(FLUTTER) analyze

format: ## Format all Dart files
	$(DART) format lib test

fix: ## Apply dart fixes
	$(DART) fix --apply

lint: analyze ## Alias for analyze

# ─── Testing ─────────────────────────────────────────────────────────────────
test: ## Run all unit/widget tests
	$(FLUTTER) test

test-coverage: ## Run tests with coverage report
	$(FLUTTER) test --coverage
	@command -v genhtml >/dev/null 2>&1 && genhtml coverage/lcov.info -o coverage/html && echo "✓ Coverage report: coverage/html/index.html" || echo "Install lcov for HTML report: brew install lcov"

test-file: ## Run a specific test file (usage: make test-file FILE=test/my_test.dart)
	$(FLUTTER) test $(FILE)

integration-test: ## Run integration tests
	$(FLUTTER) test integration_test/

# ─── Install & Deploy ────────────────────────────────────────────────────────
install-apk: build-apk ## Build and install APK on connected device
	$(FLUTTER) install

# ─── Firebase ────────────────────────────────────────────────────────────────
firebase-init: ## Configure Firebase for all platforms (FlutterFire CLI)
	flutterfire configure

# ─── Device & Debug ──────────────────────────────────────────────────────────
devices: ## List connected devices
	$(FLUTTER) devices

doctor: ## Run Flutter doctor
	$(FLUTTER) doctor -v

logs: ## Stream device logs
	$(FLUTTER) logs

screenshots: ## Take screenshot from connected device
	$(FLUTTER) screenshot -o screenshots/screenshot_$$(date +%Y%m%d_%H%M%S).png

# ─── Convenience Combos ──────────────────────────────────────────────────────
fresh: reset build-runner ## Reset + regenerate code
	@echo "✓ Fresh start ready"

ci: get analyze test ## CI pipeline: get deps → analyze → test
	@echo "✓ CI checks passed"

release-android: clean get build-appbundle ## Full Android release pipeline
	@echo "✓ Android release build ready"

release-ios: clean get build-ipa ## Full iOS release pipeline
	@echo "✓ iOS release build ready"

release-web: clean get build-web ## Full web release pipeline
	@echo "✓ Web release build ready"

ship: clean get analyze test build-all ## Full ship: clean → get → analyze → test → build all
	@echo "✓ All builds ready to ship"
