#!/bin/bash
# Tampilkan 3 aplikasi paling berat (memori digabung per aplikasi, termasuk bagian-bagian kecilnya)
top -l 1 -n 600 -stats pid,mem 2>/dev/null | awk 'NR>12 && $1 ~ /^[0-9]+$/ {print $1, $2}' > /tmp/.mr_mem.$$
ps -axo pid=,comm= > /tmp/.mr_ps.$$
awk '
  FNR==NR { v=$2; gsub(/[+-]$/,"",v); u=substr(v,length(v)); n=v+0;
            mb=(u=="G")?n*1024:(u=="M")?n:(u=="K")?n/1024:n/1048576; mem[$1]=mb; next }
  { pid=$1; $1=""; path=substr($0,2); if(!(pid in mem)) next
    name=""
    if (path ~ /\/claude-code\//) { name="Sesi kerja Claude"; sesi[pid]=1 }
    else if (path ~ /@openai\/codex/) name="Codex Terminal"
    else if (match(path,/\/[^\/]+\.app\//)) { name=substr(path,RSTART+1,RLENGTH-6) }
    else if (path ~ /WebKit/) name="Safari & web app (WA/Teams)"
    else next
    if (name ~ /^(Safari|Web App)$/) name="Safari & web app (WA/Teams)"
    if (name ~ /Helper/) next
    if (name=="ChatGPT") name="ChatGPT (Codex)"
    tot[name]+=mem[pid] }
  END { for (k in sesi) ns++; for (k in tot) { lab=k; if (k=="Sesi kerja Claude") lab=k " x" ns; printf "%.0f\t%s\n", tot[k], lab } }' /tmp/.mr_mem.$$ /tmp/.mr_ps.$$ \
| sort -rn | grep -vE "\t(WindowServer|Finder|Dock|loginwindow|SystemUIServer|Control Center|NotificationCenter)$" | head -3 \
| awk -F'\t' '{ printf "%s (%.1f GB)\n", $2, $1/1024 }'
rm -f /tmp/.mr_mem.$$ /tmp/.mr_ps.$$
