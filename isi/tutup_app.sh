#!/bin/bash
# Pakai: tutup_app.sh ringan|semua [--coba]
# ringan = tutup app yang tidak penting. semua = tutup semua app kecuali Finder.
# --coba = hanya tampilkan daftar, tidak menutup apa pun.
MODE="$1"; COBA="$2"
[ "$MODE" = "ringan" ] && [ -f "$HOME/Library/Application Support/ModeRingan/pilih_sekali" ] && [ "$COBA" != "--coba" ] && exec "$HOME/Library/Application Support/ModeRingan/tutup_pilihan.sh"
F_OTO="$HOME/Library/Application Support/ModeRingan/mode_otomatis"
[ -f "$F_OTO" ] && [ "$MODE" = "ringan" ] && { COBA="--otomatis"; rm -f "$F_OTO"; }
F_AS="$HOME/Library/Application Support/ModeRingan/otomatis_semua"
[ -f "$F_AS" ] && [ "$MODE" = "semua" ] && { COBA="--langsung"; rm -f "$F_AS"; }
# Diklik manual dari Dock (tanpa penanda apa pun) -> tampilkan kotak pilihan dulu
[ -z "$COBA" ] && exec "$HOME/Library/Application Support/ModeRingan/kotak_manual.sh" "$MODE"
RINGAN="us.zoom.xos com.spotify.client com.hnc.Discord org.libreoffice.script com.apple.Preview com.apple.Stickies com.apple.ScreenContinuity com.pdfeditor.pdfeditormac"
# App latar belakang (hanya ikon di menu bar) yang ikut ditutup oleh "semua"
LATAR_SEMUA="dev.kdrag0n.MacVirt com.hnc.Discord us.zoom.xos com.spotify.client"
JANGAN="com.apple.finder"
JANGAN_NAMA="Mode Ringan|Tutup Semua"

daftar=(); sudah=""
F_KEC="$HOME/Library/Application Support/ModeRingan/kecuali_sekali"
KECUALI=""; [ -f "$F_KEC" ] && [ "$COBA" != "--coba" ] && { KECUALI=$(cat "$F_KEC"); rm -f "$F_KEC"; }
while IFS='|' read -r nama bid; do
  [ -z "$bid" ] && continue
  case " $JANGAN " in *" $bid "*) continue;; esac
  echo "$nama" | grep -qE "^($JANGAN_NAMA)$" && continue
  if [ "$MODE" = "ringan" ]; then
    [ "$bid" = "us.zoom.xos" ] && pgrep -x CptHost >/dev/null && continue
    case " $RINGAN " in *" $bid "*) ;; *) continue;; esac
  fi
  [ -n "$KECUALI" ] && printf '%s\n' "$KECUALI" | grep -qxF "$nama" && continue
  case " $sudah " in *" $bid "*) continue;; esac
  sudah="$sudah $bid"
  daftar+=("$nama|$bid")
done < <(lsappinfo list | awk '
  /^ *[0-9]+\) "/{ match($0,/"[^"]*"/); n=substr($0,RSTART+1,RLENGTH-2); b="" }
  /bundleID=/{ match($0,/bundleID="[^"]*"/); b=substr($0,RSTART+10,RLENGTH-11) }
  /type="Foreground"/{ gsub(/\xe2\x80\x8e/,"",n); print n "|" b }'
  # Tambahan: app yang jalan di latar belakang tapi tetap perlu dicek
  if [ "$MODE" = "ringan" ]; then EKSTRA="$RINGAN"; else EKSTRA="$LATAR_SEMUA"; fi
  for x in $EKSTRA; do
    asn=$(lsappinfo find bundleID=$x); [ -z "$asn" ] && continue
    nm=$(echo "$asn" | sed -E 's/.*-"([^"]*)".*/\1/'); echo "$nm|$x"
  done)

if [ ${#daftar[@]} -eq 0 ]; then
  [ "$COBA" = "--coba" ] && echo "(tidak ada app yang perlu ditutup)"; [ "$COBA" = "--otomatis" ] && exit 0; [ "$COBA" = "--coba" ] || osascript -e "display dialog \"✅ Tombol jalan — tidak ada app yang perlu ditutup.\" with title \"$([ "$MODE" = "semua" ] && echo "Tutup Semua" || echo "Mode Ringan")\" buttons {\"OK\"} default button \"OK\" giving up after 4" >/dev/null 2>&1
  exit 0
fi

nama_list=""
for x in "${daftar[@]}"; do
  nama="${x%%|*}"; bid="${x##*|}"
  nama_list="$nama_list$nama, "
  if [ "$COBA" = "--coba" ]; then echo "AKAN DITUTUP: $nama ($bid)"; continue; fi
  # Tutup cara biasa (seperti Cmd+Q). Kalau ada file belum disimpan, app akan bertanya dulu.
  osascript -e "tell application id \"$bid\" to quit" >/dev/null 2>&1 &
done
[ "$COBA" = "--coba" ] && exit 0
judul=$([ "$MODE" = "semua" ] && echo "Tutup Semua" || echo "Mode Ringan"); [ "$COBA" = "--otomatis" ] && judul="Mode Ringan otomatis (memori kuning)"
# Claude ikut ditutup -> laporan tetap muncul karena kotak dijalankan oleh tombol ini, bukan oleh Claude
"$HOME/Library/Application Support/ModeRingan/tunggu_tutup.sh" "$judul" "${daftar[@]}"
