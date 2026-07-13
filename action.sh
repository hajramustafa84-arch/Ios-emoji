#!/system/bin/sh

MODDIR="${0%/*}"
SCRIPT="$MODDIR/service.sh"

set +o standalone 2>/dev/null
unset ASH_STANDALONE 2>/dev/null

if [ ! -f "$SCRIPT" ]; then
  echo "Missing service.sh"
  exit 1
fi

sh "$SCRIPT"
