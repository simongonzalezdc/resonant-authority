#!/bin/sh
# Resonant Authority add-on entrypoint (delegation contract):
# reads TASK.md from the delegation dir (arg 1 or cwd), writes artifact.md.
# Exit code = 0 only if TASK.md is well-formed AND every directive succeeded.
# Task grammar (exactly one directive per line; delegation.packet.json is ignored):
#   dimensions: D1,D2[|weights D1=0.5,D2=0.5]   (exactly 2 segments max)
#   record: DATE|DIM|LANE|VERDICT|SOURCE        (exactly 5 fields)
set -u
DIR="${1:-$(pwd)}"
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$DIR/artifact.md"
status=0
if [ ! -f "$DIR/TASK.md" ]; then
  printf 'resonant-authority: no TASK.md in delegation dir\n' > "$OUT"; exit 1
fi
: > "$OUT"
directives=0
while IFS= read -r line || [ -n "$line" ]; do
  line=$(printf '%s\n' "$line" | tr -d '\r')
  # blank and #-comment lines are ignored
  case "$line" in ''|'#'*) continue ;; esac
  case "$line" in
    dimensions:*)
      directives=$((directives+1))
      ARGS=$(printf '%s' "$line" | sed 's/^dimensions:[[:space:]]*//')
      SEG=$(printf '%s' "$ARGS" | awk -F'|' '{print NF}')
      if [ "$SEG" -gt 2 ]; then
        printf 'REFUSED (too many | segments in dimensions directive): %s\n' "$line" >> "$OUT"; status=1; continue
      fi
      DIMS=$(printf '%s' "$ARGS" | cut -d'|' -f1 | tr -d ' ')
      WTS=$(printf '%s' "$ARGS" | cut -s -d'|' -f2 | tr -d ' ')
      if [ -n "$WTS" ]; then
        "$HERE/tools/authority" question --dimensions "$DIMS" --weights "$WTS" >> "$OUT" 2>&1 || status=1
      else
        "$HERE/tools/authority" question --dimensions "$DIMS" >> "$OUT" 2>&1 || status=1
      fi
      ;;
    record:*)
      directives=$((directives+1))
      BODY=$(printf '%s' "$line" | sed 's/^record:[[:space:]]*//')
      NF=$(printf '%s' "$BODY" | awk -F'|' '{print NF}')
      if [ "$NF" -ne 5 ]; then
        printf 'REFUSED (record needs exactly 5 |-separated fields, got %s): %s\n' "$NF" "$line" >> "$OUT"; status=1; continue
      fi
      IFS='|' read -r D DIM LANE VERDICT SRC <<EOF2
$BODY
EOF2
      "$HERE/tools/authority" record --date "$D" --dimension "$DIM" --lane "$LANE" --verdict "$VERDICT" --source "$SRC" >> "$OUT" 2>&1 || status=1
      ;;
    *)
      printf 'REFUSED (unknown directive; expected dimensions: or record:): %s\n' "$line" >> "$OUT"; status=1
      ;;
  esac
done < "$DIR/TASK.md"
if [ "$directives" -eq 0 ]; then
  printf 'REFUSED (TASK.md contains no directives)\n' >> "$OUT"; status=1
fi
printf 'artifact written: %s (%s directives, status %s)\n' "$OUT" "$directives" "$status"
exit $status
