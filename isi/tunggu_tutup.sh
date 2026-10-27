#!/bin/bash
# Pakai: tunggu_tutup.sh "Judul" "nama|bundleid" ...
# Menunggu app benar-benar tertutup (maks 20 detik), lalu melapor jujur mana yang tertutup & mana yang belum.
JUDUL="$1"; shift
for i in $(seq 1 20); do
  sisa=0; for x in "$@"; do [ -n "$(lsappinfo find bundleID="${x##*|}")" ] && sisa=1; done
  [ $sisa = 0 ] && break; sleep 1
done
ok=""; belum=""
for x in "$@"; do
  if [ -n "$(lsappinfo find bundleID="${x##*|}")" ]; then belum="$belum\n- ${x%%|*}"; else ok="$ok\n- ${x%%|*}"; fi
done
PESAN=""; [ -n "$ok" ] && PESAN="✅ Sudah ditutup:$ok"
[ -n "$belum" ] && PESAN="$PESAN$([ -n "$ok" ] && echo '\n\n')⚠️ Masih terbuka:$belum\n\n(Mungkin sedang menanyakan file yang belum disimpan, atau kamu belum klik Allow saat Mac minta izin.)"
osascript -e "display dialog \"$PESAN\" with title \"$JUDUL\" buttons {\"OK\"} default button \"OK\" giving up after $([ -n "$belum" ] && echo 15 || echo 4)" >/dev/null 2>&1
