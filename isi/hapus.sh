#!/bin/bash
# Menghapus Mode Ringan dari akun Mac ini (dipindah ke Trash, bukan dihapus permanen).
D="$HOME/Library/Application Support/ModeRingan"; A="$HOME/Applications"; LA="$HOME/Library/LaunchAgents"; U=$(id -u)
for L in com.thisya.moderingan.cekmemori com.thisya.moderingan.restartpagi com.moderingan.cekmemori com.moderingan.restartpagi; do
  [ "$TANPA_SISTEM" = "1" ] || launchctl bootout gui/$U/$L 2>/dev/null; rm -f "$LA/$L.plist"; done
mkdir -p "$HOME/.Trash"
for x in "$A/Mode Ringan.app" "$A/Tutup Semua.app" "$D"; do [ -e "$x" ] && mv "$x" "$HOME/.Trash/$(basename "$x") $(date +%H%M%S)"; done
if [ "$TANPA_SISTEM" != "1" ]; then
  python3 - <<'PY'
import plistlib,os,subprocess
p=os.path.expanduser('~/Library/Preferences/com.apple.dock.plist')
d=plistlib.load(open(p,'rb'))
d['persistent-apps']=[a for a in d.get('persistent-apps',[]) if not any(k in a.get('tile-data',{}).get('file-data',{}).get('_CFURLString','') for k in ('Mode%20Ringan.app','Tutup%20Semua.app'))]
plistlib.dump(d,open(p,'wb')); subprocess.run(['killall','cfprefsd']); subprocess.run(['killall','Dock'])
PY
  osascript -e 'display dialog "Mode Ringan sudah dihapus (dipindah ke Trash)." with title "Hapus Mode Ringan" buttons {"OK"} default button "OK"' >/dev/null 2>&1
fi
echo OK
