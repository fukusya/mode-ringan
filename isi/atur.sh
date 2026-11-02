#!/bin/bash
# Memilih app mana saja yang ditutup oleh Mode Ringan. Disimpan di daftar_ringan.txt (Nama|bundleid).
# Opsional (untuk tes): PILIHAN_TES="Nama1\nNama2" -> lewati kotak pilih.
D="$HOME/Library/Application Support/ModeRingan"; F="$D/daftar_ringan.txt"
BAWAAN="com.spotify.client com.hnc.Discord org.libreoffice.script com.apple.Preview com.apple.Stickies com.apple.ScreenContinuity com.pdfeditor.pdfeditormac"
JANGAN="com.apple.finder"
T=$(mktemp)
# Kandidat: semua app terpasang + yang sedang jalan
for a in /Applications/*.app /Applications/Utilities/*.app /System/Applications/*.app /System/Applications/Utilities/*.app /System/Library/CoreServices/Applications/*.app "$HOME/Applications"/*.app; do
  [ -d "$a" ] || continue
  b=$(defaults read "$a/Contents/Info.plist" CFBundleIdentifier 2>/dev/null) || continue
  n=$(basename "$a" .app); echo "$n|$b"
done >> "$T"
lsappinfo list | awk '/^ *[0-9]+\) "/{match($0,/"[^"]*"/); n=substr($0,RSTART+1,RLENGTH-2); b=""} /bundleID=/{match($0,/bundleID="[^"]*"/); b=substr($0,RSTART+10,RLENGTH-11)} /type="(Foreground|UIElement)"/{gsub(/\xe2\x80\x8e/,"",n); if(b!="") print n "|" b}' >> "$T"
[ -s "$F" ] && cat "$F" >> "$T"
# Buang tombol Mode Ringan sendiri, Finder, bagian kecil (Helper), lalu satu baris per app
CALON=$(grep -vE '^(Mode Ringan|Tutup Semua|Atur Mode Ringan|Pasang Mode Ringan|Hapus Mode Ringan)\|' "$T" | grep -viE 'helper|\|com\.apple\.finder$' | awk -F'|' 'NF==2 && !s[$2]++' | sort -f)
rm -f "$T"
# Yang sedang terpilih
if [ -f "$F" ]; then SEKARANG=$(cut -d'|' -f2 "$F"); else SEKARANG=$(echo $BAWAAN | tr ' ' '\n'); fi
osa_list(){ awk 'BEGIN{ORS=""} NF{gsub(/"/,""); printf "%s\"%s\"", (c++?", ":""), $0}'; }
SEMUA=$(printf '%s\n' "$CALON" | cut -d'|' -f1 | osa_list)
TERPILIH=$(printf '%s\n' "$CALON" | awk -F'|' -v s="$(echo $SEKARANG)" 'BEGIN{n=split(s,a," "); for(i=1;i<=n;i++) w[a[i]]=1} ($2 in w){print $1}' | osa_list)
if [ -n "${PILIHAN_TES+x}" ]; then P=$(printf "$PILIHAN_TES"); else
P=$(osascript -e "set r to choose from list {$SEMUA} with title \"Atur Mode Ringan\" with prompt \"Centang app yang boleh DITUTUP oleh Mode Ringan (tahan Cmd untuk pilih lebih dari satu). Yang tidak dicentang tidak akan disentuh.\" default items {$TERPILIH} OK button name \"Simpan\" cancel button name \"Batal\" with multiple selections allowed and empty selection allowed" -e 'if r is false then return "BATAL"' -e 'set AppleScript'"'"'s text item delimiters to linefeed' -e 'return r as text' 2>/dev/null); fi
[ "$P" = "BATAL" ] && exit 0
mkdir -p "$D"
printf '%s\n' "$P" | while IFS= read -r nm; do [ -n "$nm" ] && printf '%s\n' "$CALON" | awk -F'|' -v n="$nm" '$1==n{print; exit}'; done > "$F.baru"
mv "$F.baru" "$F"
ISI=$(cut -d'|' -f1 "$F" | tr '\n' ',' | sed 's/,$//; s/,/, /g'); [ -z "$ISI" ] && ISI="(kosong — Mode Ringan tidak akan menutup apa pun)"
[ -n "${PILIHAN_TES+x}" ] && { echo "TERSIMPAN: $ISI"; exit 0; }
osascript -e "display dialog \"✅ Tersimpan. Mode Ringan akan menutup:\n$ISI\" with title \"Atur Mode Ringan\" buttons {\"OK\"} default button \"OK\" giving up after 6" >/dev/null 2>&1
