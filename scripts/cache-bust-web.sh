#!/usr/bin/env bash
# Give build/web entry files unique per-build URLs so browsers can't keep
# serving a stale main.dart.js / flutter_bootstrap.js from their cache.
set -euo pipefail

cd "$(dirname "$0")/../build/web"

hash=$(sha256sum main.dart.js | cut -c1-12)
rm -f main.dart.*.js 2>/dev/null || true
# keep main.dart.js too, for any page still holding an old bootstrap
cp main.dart.js "main.dart.${hash}.js"
[ -f main.dart.js.map ] && mv main.dart.js.map "main.dart.${hash}.js.map"
sed -i "s/\"mainJsPath\":\"main\.dart\.js\"/\"mainJsPath\":\"main.dart.${hash}.js\"/" flutter_bootstrap.js
sed -i "s/src=\"flutter_bootstrap\.js[^\"]*\"/src=\"flutter_bootstrap.js?v=${hash}\"/" index.html

echo "Cache-busted build: main.dart.${hash}.js"
