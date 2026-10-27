#!/bin/bash
# Kotak yang muncul saat tombol Mode Ringan / Tutup Semua diklik MANUAL dari Dock (tanpa hitung mundur).
D="$HOME/Library/Application Support/ModeRingan"; MODE="$1"
TOP=$("$D/top3.sh")
APPS=$("$D/tutup_app.sh" "$MODE" --coba | sed -n 's/^AKAN DITUTUP: \(.*\) (.*)$/\1/p')
BERAT=$(printf '%s' "$TOP" | sed 's/^/• /' | awk 'BEGIN{ORS=""} {printf "%s%s", (NR>1?"\\n":""), $0}')
TEKS=$(printf '%s' "$APPS" | tr '\n' ',' | sed 's/,/, /g; s/, $//')
daftar_osa(){ awk 'BEGIN{ORS=""} NF{gsub(/"/,""); printf "%s\"%s\"", (c++?", ":""), $0}'; }
pilih(){ osascript -e "set r to choose from list {$1} with title \"$2\" with prompt \"$3\" OK button name \"$4\" cancel button name \"Batal\" with multiple selections allowed$5" -e 'if r is false then return "BATAL"' -e 'set AppleScript'"'"'s text item delimiters to linefeed' -e 'return r as text' 2>/dev/null; }

if [ "$MODE" = "ringan" ]; then
  if [ -n "$APPS" ]; then BAWAH="Mode Ringan akan menutup:\n$TEKS"; TOMBOL='{"Batal", "Pilih yang ditutup…", "Jalankan Mode Ringan"}'; DEF="Jalankan Mode Ringan"
  else BAWAH="Tidak ada app ringan yang perlu ditutup.\nKlik Pilih untuk menutup app yang berat."; TOMBOL='{"Batal", "Pilih yang ditutup…"}'; DEF="Pilih yang ditutup…"; fi
  JAWAB=$(osascript -e "display dialog \"Paling berat sekarang:\n$BERAT\n\n$BAWAH\" with title \"Mode Ringan\" buttons $TOMBOL default button \"$DEF\"" 2>/dev/null)
  case "$JAWAB" in
    *Jalankan*) "$D/tutup_app.sh" ringan --langsung;;
    *Pilih*)
      LIST=$( { printf '%s\n' "$TOP"; printf '%s\n' "$APPS"; } | awk '!s[$0]++' | daftar_osa)
      P=$(pilih "$LIST" "Mode Ringan" "Pilih app yang mau DITUTUP (tahan Cmd untuk pilih lebih dari satu)." "Tutup" "")
      [ "$P" = "BATAL" ] || [ -z "$P" ] && exit 0
      printf '%s\n' "$P" > "$D/pilih_sekali"; "$D/tutup_pilihan.sh";;
  esac
else
  JAWAB=$(osascript -e "display dialog \"Paling berat sekarang:\n$BERAT\n\nAkan ditutup:\n$TEKS\n\nFile yang belum disimpan akan ditanyakan dulu.\" with title \"Tutup Semua\" buttons {\"Batal\", \"Pilih yang tetap dibuka…\", \"Tutup Semua\"} default button \"Tutup Semua\" with icon stop" 2>/dev/null)
  case "$JAWAB" in
    *"Tutup Semua"*) "$D/tutup_app.sh" semua --langsung;;
    *Pilih*)
      P=$(printf '%s\n' "$APPS" | daftar_osa); P=$(pilih "$P" "Tutup Semua" "Pilih app yang TETAP DIBUKA (tahan Cmd untuk pilih lebih dari satu). Sisanya ditutup." "Tutup sisanya" " and empty selection allowed")
      [ "$P" = "BATAL" ] && exit 0
      printf '%s\n' "$P" > "$D/kecuali_sekali"; "$D/tutup_app.sh" semua --langsung;;
  esac
fi
