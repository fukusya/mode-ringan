#!/bin/bash
# Jalan tiap jam 08.00. Kalau Mac sedang tidur (laptop ditutup), jalan saat Mac dibuka.
# TIDAK pernah restart otomatis tanpa klik — supaya kerjaan Claude/Codex semalam tidak putus.
COBA="$1"
while true; do
  JAWAB=$(osascript -e 'display dialog "Selamat pagi ☀️\n\nRestart Mac sekarang supaya memori segar lagi?\n\nCek dulu: Claude/Codex tidak sedang bekerja & file sudah disimpan." with title "Restart Pagi" buttons {"Lewati hari ini", "Nanti 1 jam", "Restart Sekarang"} default button "Restart Sekarang"'"$([ "$COBA" = "--coba" ] && echo ' giving up after 3')" 2>/dev/null)
  case "$JAWAB" in
    *"Restart Sekarang"*)
      [ "$COBA" = "--coba" ] && { echo "AKAN RESTART"; exit 0; }
      osascript -e 'tell application "loginwindow" to «event aevtrrst»'; exit 0;;
    *"Nanti 1 jam"*) [ "$COBA" = "--coba" ] && { echo "AKAN TANYA LAGI 1 JAM"; exit 0; }; sleep 3600;;
    *) echo "dilewati"; exit 0;;
  esac
done
