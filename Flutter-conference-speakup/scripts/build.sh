#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────
# SpeakUp – Local multi-platform build script
# Usage:
#   ./scripts/build.sh [android|ios|linux|windows|macos|web|all]
# ──────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build/release-artifacts"

cd "$PROJECT_ROOT"

mkdir -p "$BUILD_DIR"

VERSION=$(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f1)
echo "🚀 Building SpeakUp v${VERSION}"
echo "──────────────────────────────────"

build_android() {
  echo "📱 Building Android APK (fat)..."
  flutter build apk --release --obfuscate --split-debug-info=build/debug-info
  cp build/app/outputs/flutter-apk/app-release.apk "$BUILD_DIR/SpeakUp-${VERSION}-android.apk"

  echo "📱 Building Android APKs (split per ABI)..."
  flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info-split
  cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk "$BUILD_DIR/SpeakUp-${VERSION}-android-arm64.apk"
  cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk "$BUILD_DIR/SpeakUp-${VERSION}-android-armv7.apk"
  cp build/app/outputs/flutter-apk/app-x86_64-release.apk "$BUILD_DIR/SpeakUp-${VERSION}-android-x86_64.apk"

  echo "📱 Building Android AAB..."
  flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info-aab
  cp build/app/outputs/bundle/release/app-release.aab "$BUILD_DIR/SpeakUp-${VERSION}-android.aab"

  echo "✅ Android builds complete"
}

build_ios() {
  echo "🍎 Building iOS IPA..."
  flutter build ipa --release --obfuscate --split-debug-info=build/debug-info-ios \
    --export-options-plist=ios/ExportOptions.plist
  cp build/ios/ipa/*.ipa "$BUILD_DIR/SpeakUp-${VERSION}-ios.ipa" 2>/dev/null || \
    echo "⚠️  IPA not generated (code signing may not be configured)"
  echo "✅ iOS build complete"
}

build_linux() {
  echo "🐧 Building Linux..."
  flutter config --enable-linux-desktop
  flutter build linux --release
  (cd build/linux/x64/release/bundle && tar czf "$BUILD_DIR/SpeakUp-${VERSION}-linux-x64.tar.gz" .)
  echo "✅ Linux build complete"
}

build_windows() {
  echo "🪟 Building Windows..."
  flutter config --enable-windows-desktop
  flutter build windows --release
  echo "✅ Windows build complete (output in build/windows/x64/runner/Release/)"
}

build_macos() {
  echo "🍏 Building macOS..."
  flutter config --enable-macos-desktop
  cd macos && pod install --repo-update && cd ..
  flutter build macos --release
  (cd build/macos/Build/Products/Release && zip -r "$BUILD_DIR/SpeakUp-${VERSION}-macos.zip" *.app)
  echo "✅ macOS build complete"
}

build_web() {
  echo "🌐 Building Web..."
  flutter build web --release --web-renderer canvaskit
  (cd build/web && tar czf "$BUILD_DIR/SpeakUp-${VERSION}-web.tar.gz" .)
  echo "✅ Web build complete"
}

TARGET="${1:-all}"

case "$TARGET" in
  android)  build_android ;;
  ios)      build_ios ;;
  linux)    build_linux ;;
  windows)  build_windows ;;
  macos)    build_macos ;;
  web)      build_web ;;
  all)
    build_android
    build_web
    # Platform-specific builds (only on matching OS)
    case "$(uname -s)" in
      Linux*)   build_linux ;;
      Darwin*)  build_ios; build_macos ;;
    esac
    echo ""
    echo "══════════════════════════════════"
    echo "📦 All builds in: $BUILD_DIR"
    ls -lh "$BUILD_DIR"
    ;;
  *)
    echo "Usage: $0 [android|ios|linux|windows|macos|web|all]"
    exit 1
    ;;
esac
