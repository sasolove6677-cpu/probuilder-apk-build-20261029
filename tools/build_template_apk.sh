#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/template_webview_source"
if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <page.html> <app-name> <package.name> [icon.png]" >&2
  exit 2
fi
HTML="$(realpath "$1")"
APP_NAME="$2"
PACKAGE_NAME="$3"
ICON="${4:-$ROOT/assets/launcher_icon.png}"
[[ -f "$HTML" ]] || { echo "HTML file not found: $HTML" >&2; exit 2; }
[[ "${HTML,,}" == *.html || "${HTML,,}" == *.htm ]] || { echo "Only .html/.htm inputs are supported." >&2; exit 2; }
[[ -f "$ICON" ]] || { echo "Icon file not found: $ICON" >&2; exit 2; }
[[ -n "${APP_NAME//[[:space:]]/}" ]] || { echo "App name cannot be empty." >&2; exit 2; }
[[ "$PACKAGE_NAME" =~ ^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$ ]] || { echo "Invalid package name: $PACKAGE_NAME" >&2; exit 2; }
command -v gradle >/dev/null || { echo "Gradle is required on PATH (Gradle 8.13 or compatible)." >&2; exit 2; }

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp -a "$TEMPLATE/." "$WORK/"
cp "$HTML" "$WORK/app/src/main/assets/index.html"
cp "$ICON" "$WORK/app/src/main/res/drawable-nodpi/launcher.png"

python3 - "$WORK" "$APP_NAME" "$PACKAGE_NAME" <<'PY'
import pathlib, re, sys, xml.etree.ElementTree as ET
root = pathlib.Path(sys.argv[1])
name, package = sys.argv[2], sys.argv[3]
gradle = root / 'app/build.gradle'
s = gradle.read_text()
s = re.sub(r"namespace\s+'[^']+'", "namespace '%s'" % package, s, count=1)
s = re.sub(r"applicationId\s+'[^']+'", "applicationId '%s'" % package, s, count=1)
gradle.write_text(s)
strings = root / 'app/src/main/res/values/strings.xml'
xml_root = ET.parse(strings).getroot()
xml_root.find("string[@name='app_name']").text = name
ET.indent(xml_root, space='    ')
ET.ElementTree(xml_root).write(strings, encoding='utf-8', xml_declaration=True)
PY

(
  cd "$WORK"
  gradle --no-daemon assembleDebug
)
APK="$WORK/app/build/outputs/apk/debug/app-debug.apk"
[[ -f "$APK" ]] || { echo "Gradle did not produce the expected APK." >&2; exit 1; }
SAFE_NAME="$(printf '%s' "$APP_NAME" | tr -cs '[:alnum:]_.-' '_' | sed 's/^_\+//;s/_\+$//')"
OUT="$HOME/Downloads/ProBuilder"
mkdir -p "$OUT"
cp "$APK" "$OUT/${SAFE_NAME:-pro-app}.apk"
echo "Debug APK created: $OUT/${SAFE_NAME:-pro-app}.apk"
echo "This APK is debug-signed for testing. Use your own protected release keystore for distribution."
