#!/usr/bin/env bash
set -euo pipefail

NID3="${HANDBOOK_NID:-278625}"
LANGUAGE="${HANDBOOK_LANGUAGE:-en}"
OUTPUT="${1:-${HANDBOOK_OUTPUT:-MuseScore-3-handbook-en-AU.pdf}}"
TITLE="${HANDBOOK_TITLE:-MuseScore 3 handbook (Australian English)}"

WKHTMLTOPDF="${WKHTMLTOPDF:-wkhtmltopdf}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XSL="${HANDBOOK_XSL:-$SCRIPT_DIR/custom.xslt}"

case "$OUTPUT" in
    /*) TARGET="$OUTPUT" ;;
    *) TARGET="$PWD/$OUTPUT" ;;
esac

TARGET_DIR="$(dirname "$TARGET")"
if [ ! -d "$TARGET_DIR" ]; then
    echo "Output directory does not exist: $TARGET_DIR" >&2
    exit 1
fi

TMPDIR="$(mktemp -d)"
cleanup() {
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

PDF_BASENAME="$(basename "$TARGET")"
TIME="$(date +%s)"
SOURCE_URL="https://musescore.org/${LANGUAGE}/print/book/export/html/${NID3}?pdf=1&no-cache=${TIME}"
COVER_URL="https://musescore.org/${LANGUAGE}/handbook-cover"

echo "Generating $TARGET"
"$WKHTMLTOPDF" \
    --encoding utf-8 \
    --load-error-handling ignore \
    --load-media-error-handling ignore \
    --footer-center '[page]' \
    --footer-spacing 2 \
    --title "$TITLE" \
    cover "$COVER_URL" \
    toc \
    --xsl-style-sheet "$XSL" \
    "$SOURCE_URL" \
    "$TMPDIR/$PDF_BASENAME"

install -m 0644 "$TMPDIR/$PDF_BASENAME" "$TARGET"
echo "Wrote $TARGET"
