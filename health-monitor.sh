#!/bin/bash
# health-monitor.sh
# Watchdog fara LLM - ruleaza prin: hermes cron create "every 15m" --no-agent --script health-monitor.sh
# Regula: iese TACUT (fara output) daca totul e OK. Scrie pe stdout DOAR daca e o problema.
# Cron livreaza pe Telegram doar cand exista output - nu spam-uieste inutil.

THRESHOLD_DISK=90
THRESHOLD_MEM=90

DISK=$(df -h / | awk 'NR==2{print $5}' | tr -d '%')
MEM=$(free | awk '/Mem:/{printf "%.0f", $3/$2*100}')
PROC_COUNT=$(pgrep -f "hermes" | wc -l)

ALERT=""

if [ "$DISK" -ge "$THRESHOLD_DISK" ]; then
  ALERT="${ALERT}⚠️ Disk aproape plin: ${DISK}%. "
fi

if [ "$MEM" -ge "$THRESHOLD_MEM" ]; then
  ALERT="${ALERT}⚠️ Memorie RAM: ${MEM}% folosita. "
fi

if [ "$PROC_COUNT" -eq 0 ]; then
  ALERT="${ALERT}⚠️ Niciun proces Hermes activ pe server! "
fi

if [ -n "$ALERT" ]; then
  echo "$ALERT"
fi
