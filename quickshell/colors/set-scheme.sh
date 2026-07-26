#!/usr/bin/env bash
# Switch the active shell colour scheme.
#
#   Usage:  set-scheme.sh <name>      # e.g. set-scheme.sh dracula
#           set-scheme.sh             # list available schemes + show current
#
# Repoints colors/current.json at colors/<name>.json. Every component reads
# current.json (polled), so the change applies live — no restart needed.

set -euo pipefail
DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

list() {
    echo "Available schemes:"
    for f in "$DIR"/*.json; do
        [ -e "$f" ] || continue
        n="$(basename "$f" .json)"
        [ "$n" = "current" ] && continue
        marker=""
        [ "$(readlink "$DIR/current.json" 2>/dev/null)" = "$n.json" ] && marker="  <- current"
        echo "  $n$marker"
    done
}

if [ $# -eq 0 ]; then
    list
    exit 0
fi

name="$1"
target="$DIR/$name.json"
if [ ! -f "$target" ]; then
    echo "No such scheme: $name" >&2
    list >&2
    exit 1
fi

ln -sfn "$name.json" "$DIR/current.json"
echo "Colour scheme -> $name"
