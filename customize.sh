#!/system/bin/sh

AUTOMOUNT=true
PROPFILE=false
POSTFSDATA=false
LATESTARTSERVICE=true

ui_print "*************************************"
ui_print "*        iOS Emoji Module 2.051     *"
ui_print "*************************************"
ui_print "- Target: Magisk + KernelSU"
ui_print "- Preparing font aliases"

FONT_DIR="$MODPATH/system/fonts"
MAIN_FONT="$FONT_DIR/NotoColorEmoji.ttf"

if [ ! -f "$MAIN_FONT" ]; then
  abort "! Missing $MAIN_FONT"
fi

# OEM and legacy aliases used by different ROMs/apps.
ALIASES="
SamsungColorEmoji.ttf
LGNotoColorEmoji.ttf
HTC_ColorEmoji.ttf
AndroidEmoji-htc.ttf
ColorUniEmoji.ttf
DcmColorEmoji.ttf
CombinedColorEmoji.ttf
NotoColorEmojiLegacy.ttf
"

for alias in $ALIASES; do
  cp -f "$MAIN_FONT" "$FONT_DIR/$alias"
done

set_perm_recursive "$MODPATH" 0 0 0755 0644
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/service.sh" 0 0 0755
ui_print "- Done"
