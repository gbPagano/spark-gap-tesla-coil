#!/usr/bin/env bash
set -e

FILE="${1:-main.typ}"
PDF="${FILE%.typ}.pdf"

typst compile "$FILE"
zathura "$PDF" &

typst watch "$FILE"
