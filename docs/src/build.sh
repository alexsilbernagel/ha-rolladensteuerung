#!/usr/bin/env bash
# Baut die beiden Dokumentations-PDFs aus den HTML-Quellen.
# Voraussetzung: wkhtmltopdf (0.12.x) und die Schriftfamilie "DejaVu Sans".
# Aufruf aus dem Repo-Root:  docs/src/build.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
OUT="$(dirname "$SRC")"
VERSION="$(grep -m1 -oE 'V[0-9]+' "$SRC/Dokumentation_DE.html")"

common=(--enable-local-file-access --encoding utf-8 --page-size A4
        --margin-top 16mm --margin-bottom 18mm --margin-left 15mm --margin-right 15mm
        --footer-font-size 7 --footer-font-name "DejaVu Sans" --footer-spacing 4 --quiet)

wkhtmltopdf "${common[@]}" \
  --footer-left "Master-Rolladensteuerung ${VERSION} - Dokumentation" \
  --footer-right "Seite [page] von [topage]" \
  "$SRC/Dokumentation_DE.html" "$OUT/Dokumentation_DE.pdf"

wkhtmltopdf "${common[@]}" \
  --footer-left "Master Roller Shutter Control ${VERSION} - Documentation" \
  --footer-right "Page [page] of [topage]" \
  "$SRC/Documentation_EN.html" "$OUT/Documentation_EN.pdf"

echo "PDFs fuer ${VERSION} erzeugt in $OUT"
