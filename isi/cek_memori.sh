#!/bin/bash
# Jalan otomatis tiap 1 menit. Level memori: 1 = hijau, 2 = kuning, 4 = merah.
#  KUNING -> kotak 5 detik berisi daftar app; diam = Mode Ringan jalan, bisa Batal. Maks 1x / 30 menit.
#  MERAH  -> kotak 30 detik; diam = Tutup Semua; bisa Batal atau pilih app yang tetap dibuka. Maks 1x / 15 menit.
D="$HOME/Library/Application Support/ModeRingan"
LEVEL=$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)
NOW=$(date +%s)
boleh(){ [ ! -f "$D/$1" ] || [ "$NOW" -ge "$(cat "$D/$1")" ]; }
berat(){ "$D/top3.sh" | sed 's/^/• /' | awk 'BEGIN{ORS=""} {printf "%s%s", (NR>1?"\\n":""), $0}'; }
daftar(){ "$D/tutup_app.sh" "$1" --coba | sed -n 's/^AKAN DITUTUP: \(.*\) (.*)$/\1/p'; }

if [ "${LEVEL:-1}" -ge 4 ]; then
  boleh jeda_merah || exit 0
  echo $((NOW + 900)) > "$D/jeda_merah"
  APPS=$(daftar semua); [ -z "$APPS" ] && exit 0
  TEKS=$(printf '%s' "$APPS" | tr '\n' ',' | sed 's/,/, /g')
  JAWAB=$(osascript -e "display dialog \"Memori Mac MERAH — sebentar lagi bisa hang.\n\nPaling berat sekarang:\n$(berat)\n\nDalam 30 detik akan ditutup:\n$TEKS\n\nFile yang belum disimpan akan ditanyakan dulu.\" with title \"Tutup Semua\" buttons {\"Batal\", \"Pilih yang tetap dibuka…\", \"Tutup Semua\"} default button \"Tutup Semua\" with icon stop giving up after 30" 2>/dev/null)
  case "$JAWAB" in
    *Batal*) exit 0;;
    *Pilih*)
      LIST=$(printf '%s' "$APPS" | awk 'BEGIN{ORS=""} {gsub(/"/,""); printf "%s\"%s\"", (NR>1?", ":""), $0}')
      PILIH=$(osascript -e "set r to choose from list {$LIST} with title \"Tutup Semua\" with prompt \"Pilih app yang TETAP DIBUKA (tahan Cmd untuk pilih lebih dari satu). Sisanya ditutup.\" OK button name \"Tutup sisanya\" cancel button name \"Batal\" with multiple selections allowed and empty selection allowed" -e 'if r is false then return "BATAL"' -e 'set AppleScript'"'"'s text item delimiters to linefeed' -e 'return r as text' 2>/dev/null)
      [ "$PILIH" = "BATAL" ] && exit 0
      printf '%s\n' "$PILIH" > "$D/kecuali_sekali";;
  esac
  touch "$D/otomatis_semua"; open -a "$HOME/Applications/Tutup Semua.app"
elif [ "${LEVEL:-1}" -ge 2 ]; then
  boleh jeda_kuning || exit 0
  echo $((NOW + 1800)) > "$D/jeda_kuning"
  TOP=$("$D/top3.sh"); APPS=$(daftar ringan)
  BERAT=$(printf '%s' "$TOP" | sed 's/^/• /' | awk 'BEGIN{ORS=""} {printf "%s%s", (NR>1?"\\n":""), $0}')
  if [ -n "$APPS" ]; then
    TEKS=$(printf '%s' "$APPS" | tr '\n' ',' | sed 's/,/, /g')
    BAWAH="Dalam 5 detik Mode Ringan akan menutup:\n$TEKS"; TOMBOL='{"Batal", "Pilih yang ditutup…", "Jalankan Sekarang"}'; DEF="Jalankan Sekarang"
  else
    BAWAH="Tidak ada app ringan yang bisa ditutup otomatis.\nKlik Pilih untuk menutup app yang berat."; TOMBOL='{"Abaikan", "Pilih yang ditutup…"}'; DEF="Abaikan"
  fi
  JAWAB=$(osascript -e "display dialog \"Memori Mac KUNING (mulai berat).\n\nPaling berat sekarang:\n$BERAT\n\n$BAWAH\" with title \"Mode Ringan\" buttons $TOMBOL default button \"$DEF\" with icon caution giving up after 5" 2>/dev/null)
  case "$JAWAB" in
    *Batal*|*Abaikan*) exit 0;;
    *"gave up:true"*) [ -z "$APPS" ] && exit 0;;
    *Pilih*)
      PILIHAN=$( { printf '%s\n' "$TOP"; printf '%s\n' "$APPS"; } | grep -v '^$' | awk '!s[$0]++')
      LIST=$(printf '%s' "$PILIHAN" | awk 'BEGIN{ORS=""} {gsub(/"/,""); printf "%s\"%s\"", (NR>1?", ":""), $0}')
      PILIH=$(osascript -e "set r to choose from list {$LIST} with title \"Mode Ringan\" with prompt \"Pilih app yang mau DITUTUP (tahan Cmd untuk pilih lebih dari satu).\" OK button name \"Tutup\" cancel button name \"Batal\" with multiple selections allowed" -e 'if r is false then return "BATAL"' -e 'set AppleScript'"'"'s text item delimiters to linefeed' -e 'return r as text' 2>/dev/null)
      [ "$PILIH" = "BATAL" ] || [ -z "$PILIH" ] && exit 0
      printf '%s\n' "$PILIH" > "$D/pilih_sekali"; open -a "$HOME/Applications/Mode Ringan.app"; exit 0;;
  esac
  touch "$D/mode_otomatis"; open -a "$HOME/Applications/Mode Ringan.app"
fi
