#!/usr/bin/env bash
# Offline-first guard: the app must not request the INTERNET permission in
# release. Checks the source manifest, and the merged release manifest if a
# release build exists. Run after `flutter build apk --flavor <f> --release`
# (or appbundle) for the full check; works without a build too.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
main=android/app/src/main/AndroidManifest.xml
# A <uses-permission> for INTERNET is only allowed with tools:node="remove",
# which strips it from the merged manifest (a library may add it back).
if perl -0ne 'while (/<uses-permission\b[^>]*android\.permission\.INTERNET[^>]*>/gs) { exit 1 unless $& =~ /tools:node="remove"/ }' "$main"; then
  :
else
  echo "FAIL: $main declares android.permission.INTERNET" >&2
  fail=1
fi

# Debug/profile manifests may declare INTERNET (Flutter tooling needs it).
# Anything that is not main/debug/profile (e.g. a release or flavor overlay)
# must not.
while IFS= read -r f; do
  case "$f" in
    */src/main/*|*/src/debug/*|*/src/profile/*) ;;
    *)
      if grep -q 'android.permission.INTERNET' "$f"; then
        echo "FAIL: $f declares android.permission.INTERNET" >&2
        fail=1
      fi
      ;;
  esac
done < <(find android/app/src -name AndroidManifest.xml)

merged=$(find build/app/intermediates -path '*Release*' \
  -name AndroidManifest.xml 2>/dev/null | grep -i merged || true)
if [ -n "$merged" ]; then
  while IFS= read -r f; do
    if grep -q 'android.permission.INTERNET' "$f"; then
      echo "FAIL: merged release manifest $f declares INTERNET" >&2
      fail=1
    else
      echo "ok: $f"
    fi
  done <<<"$merged"
else
  echo "note: no merged release manifest found; checked sources only"
fi

if [ "$fail" -ne 0 ]; then exit 1; fi
echo "manifest check passed"
