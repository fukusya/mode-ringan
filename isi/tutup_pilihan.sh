#!/bin/bash
# Menutup app yang dipilih dari kotak "Pilih yang ditutup…". Nama dibaca dari file pilih_sekali (satu per baris).
D="$HOME/Library/Application Support/ModeRingan"; F="$D/pilih_sekali"; COBA="$1"
[ -f "$F" ] || exit 0
target=(); catatan=""
while IFS= read -r baris; do
  [ -z "$baris" ] && continue
  nama=$(echo "$baris" | sed -E 's/^• //; s/ \([0-9.]+ GB\)$//; s/ x[0-9]+$//')
  case "$nama" in
    "Sesi kerja Claude"|"Claude") target+=("Claude (+ semua sesinya)|com.anthropic.claudefordesktop");;
    "ChatGPT (Codex)") target+=("ChatGPT (Codex)|com.openai.codex");;
    "Codex Terminal") catatan="\n\n(Codex Terminal tidak ditutup: dipakai Claude untuk review.)";;
    "Safari & web app (WA/Teams)")
      for x in com.apple.Safari $(lsappinfo list | grep -o 'bundleID="com.apple.Safari.WebApp[^"]*"' | cut -d'"' -f2); do
        [ -n "$(lsappinfo find bundleID=$x)" ] && target+=("$(lsappinfo find bundleID=$x | sed -E 's/.*-"([^"]*)".*/\1/')|$x")
      done;;
    *) bid=$(osascript -e "id of application \"$nama\"" 2>/dev/null); [ -n "$bid" ] && target+=("$nama|$bid");;
  esac
done < "$F"
rm -f "$F"
for x in "${target[@]}"; do
  if [ "$COBA" = "--coba" ]; then echo "AKAN DITUTUP: ${x%%|*} (${x##*|})"; else osascript -e "tell application id \"${x##*|}\" to quit" >/dev/null 2>&1 & fi
done
[ "$COBA" = "--coba" ] && exit 0
[ ${#target[@]} -eq 0 ] && { osascript -e "display dialog \"Tidak ada yang ditutup.$catatan\" with title \"Mode Ringan\" buttons {\"OK\"} giving up after 4" >/dev/null 2>&1; exit 0; }
"$D/tunggu_tutup.sh" "Mode Ringan" "${target[@]}"
