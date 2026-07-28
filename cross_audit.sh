#!/bin/bash
# cross_audit.sh — verifică dacă fiecare din cei 4 agenți chiar RĂSPUNDE
# (diferit de health-monitor.sh, care verifică resursele serverului, nu agenții)
# Rulează prin cron --no-agent, la fiecare oră

LOG=~/Desktop/Agents/COMUN/logs/cross_audit_$(date +%Y%m%d).jsonl
mkdir -p "$(dirname "$LOG")"
TIMESTAMP=$(date -Iseconds)
DEAD_LIST=""

for agent in alexandra gheorghe vasile dinu; do
    RESPONSE=$($agent --print "Ping: status?" 2>&1)
    if echo "$RESPONSE" | grep -qi "error\|timeout\|failed"; then
        echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"DEAD\"}" >> "$LOG"
        DEAD_LIST="$DEAD_LIST $agent"
    else
        echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"ALIVE\"}" >> "$LOG"
    fi
done

# Iese cu output DOAR daca exista o problema (health-monitor livreaza pe Telegram doar atunci)
if [ -n "$DEAD_LIST" ]; then
    echo "⚠️ Agenti care nu raspund:$DEAD_LIST"
fi
