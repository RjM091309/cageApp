#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

export PATH="/opt/flutter/bin:${HOME}/.nvm/versions/node/v20.18.0/bin:${PATH}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Install Flutter and ensure it is on PATH." >&2
  exit 1
fi

if [ ! -d web ]; then
  echo "Enabling Flutter web platform..."
  flutter create . --platforms=web --project-name appcage_flutter
fi

echo "Installing Flutter dependencies..."
flutter pub get

echo "Building Flutter web (release)..."
flutter build web --release
