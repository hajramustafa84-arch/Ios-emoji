#!/system/bin/sh

MODDIR="${0%/*}"
FONT="$MODDIR/system/fonts/NotoColorEmoji.ttf"
LOG="$MODDIR/service.log"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$LOG"
}

wait_until_booted() {
  until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 5
  done
  until [ -d /sdcard ]; do
    sleep 3
  done
}

bind_mount_font() {
  target="$1"
  [ -f "$FONT" ] || return 1
  [ -e "$target" ] || return 0
  mount -o bind "$FONT" "$target" 2>/dev/null || return 1
  chmod 0644 "$target" 2>/dev/null
  return 0
}

replace_file_font() {
  target="$1"
  [ -f "$FONT" ] || return 1
  [ -f "$target" ] || return 0
  cp -f "$FONT" "$target" 2>/dev/null || return 1
  chmod 0644 "$target" 2>/dev/null
  return 0
}

replace_known_app_fonts() {
  TARGETS="
/data/data/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf
/data/data/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf
/data/data/com.facebook.lite/files/emoji_font.ttf
/data/data/com.facebook.mlite/files/emoji_font.ttf
/data/user/0/com.facebook.orca/app_ras_blobs/FacebookEmoji.ttf
/data/user/0/com.facebook.katana/app_ras_blobs/FacebookEmoji.ttf
/data/user/0/com.facebook.lite/files/emoji_font.ttf
/data/user/0/com.facebook.mlite/files/emoji_font.ttf
"

  for target in $TARGETS; do
    replace_file_font "$target" && log "replaced app font: $target"
  done
}

replace_discovered_app_fonts() {
  for base in /data/data /data/user/0; do
    [ -d "$base" ] || continue
    find "$base" -type f -iname "*emoji*.ttf" 2>/dev/null | while IFS= read -r file; do
      replace_file_font "$file" && log "replaced discovered font: $file"
    done
  done
}

clean_system_font_caches() {
  [ -d /data/fonts ] && rm -rf /data/fonts 2>/dev/null && log "removed /data/fonts"
  find /data -type d -path "*com.google.android.gms/files/fonts*" 2>/dev/null | while IFS= read -r dir; do
    rm -rf "$dir" 2>/dev/null && log "removed gms font dir: $dir"
  done
}

stop_target_apps() {
  APPS="com.facebook.orca com.facebook.katana com.facebook.lite com.facebook.mlite com.google.android.inputmethod.latin"
  for app in $APPS; do
    am force-stop "$app" 2>/dev/null
  done
}

run() {
  [ -f "$FONT" ] || exit 0
  wait_until_booted
  log "service start"

  # System font replacement paths used across ROMs.
  for target in /system/fonts/NotoColorEmoji.ttf /system/product/fonts/NotoColorEmoji.ttf /product/fonts/NotoColorEmoji.ttf; do
    bind_mount_font "$target" && log "bind mounted: $target"
  done

  replace_known_app_fonts
  replace_discovered_app_fonts
  clean_system_font_caches
  stop_target_apps
  log "service done"
}

run
