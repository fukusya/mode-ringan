#!/bin/bash
# Pemasang Mode Ringan. Semua file dipasang hanya untuk akun Mac yang sedang dipakai.
# Variabel opsional (untuk tes): TANPA_SISTEM=1 -> tidak memasang pengecek otomatis & Dock. RESTART=ya|tidak -> lewati pertanyaan.
SRC="$(cd "$(dirname "$0")" && pwd)"
D="$HOME/Library/Application Support/ModeRingan"; A="$HOME/Applications"; LA="$HOME/Library/LaunchAgents"
mkdir -p "$D" "$A" "$LA"
cp "$SRC"/cek_memori.sh "$SRC"/kotak_manual.sh "$SRC"/restart_pagi.sh "$SRC"/top3.sh "$SRC"/tunggu_tutup.sh "$SRC"/tutup_app.sh "$SRC"/tutup_pilihan.sh "$D/"
chmod +x "$D"/*.sh
buat_tombol(){ # nama, mode, ikon
  rm -rf "$A/$1.app"
  osacompile -o "$A/$1.app" -e "do shell script \"'\" & POSIX path of (path to home folder) & \"Library/Application Support/ModeRingan/tutup_app.sh' $2\"" || return 1
  cp "$SRC/$3" "$A/$1.app/Contents/Resources/applet.icns"
  rm -f "$A/$1.app/Contents/Resources/Assets.car"; plutil -remove CFBundleIconName "$A/$1.app/Contents/Info.plist" 2>/dev/null
  codesign -f -s - "$A/$1.app" 2>/dev/null; touch "$A/$1.app"
}
buat_tombol "Mode Ringan" ringan ringan.icns && buat_tombol "Tutup Semua" semua semua.icns || { echo GAGAL membuat tombol; exit 1; }
[ "$TANPA_SISTEM" = "1" ] && { echo "OK (tanpa pengecek otomatis & Dock)"; exit 0; }
U=$(id -u)
# bersihkan versi lama (nama lama & baru) supaya tidak dobel
for L in com.thisya.moderingan.cekmemori com.thisya.moderingan.restartpagi com.moderingan.cekmemori com.moderingan.restartpagi; do
  launchctl bootout gui/$U/$L 2>/dev/null; rm -f "$LA/$L.plist"; done
agen(){ # label, script, kunci-jadwal
  cat > "$LA/$1.plist" <<P
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>Label</key><string>$1</string>
<key>ProgramArguments</key><array><string>/bin/bash</string><string>$D/$2</string></array>
$3</dict></plist>
P
  launchctl bootstrap gui/$U "$LA/$1.plist"; }
agen com.moderingan.cekmemori cek_memori.sh "<key>StartInterval</key><integer>60</integer><key>RunAtLoad</key><true/>"
if [ -z "$RESTART" ]; then
  J=$(osascript -e 'display dialog "Pasang juga pengingat restart tiap jam 8 pagi?\n(Mac tidak akan restart tanpa kamu klik.)" with title "Pasang Mode Ringan" buttons {"Tidak", "Ya"} default button "Ya"' 2>/dev/null)
  echo "$J" | grep -q "Ya" && RESTART=ya || RESTART=tidak
fi
[ "$RESTART" = "ya" ] && agen com.moderingan.restartpagi restart_pagi.sh "<key>StartCalendarInterval</key><dict><key>Hour</key><integer>8</integer><key>Minute</key><integer>0</integer></dict>"
for n in "Mode Ringan" "Tutup Semua"; do
  defaults read com.apple.dock persistent-apps 2>/dev/null | grep -q "${n// /%20}.app" || defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>file://$A/${n// /%20}.app/</string><key>_CFURLStringType</key><integer>15</integer></dict></dict></dict>"
done
killall Dock
osascript -e 'display dialog "✅ Mode Ringan sudah terpasang.\n\nDua tombol baru ada di Dock: Mode Ringan (daun) dan Tutup Semua (merah).\nPertama kali dipakai, klik Allow kalau Mac minta izin." with title "Pasang Mode Ringan" buttons {"OK"} default button "OK" giving up after 20' >/dev/null 2>&1
echo OK
