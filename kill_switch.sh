#!/bin/bash
# kill_switch.sh — Oprește toți cei 4 agenți în caz de urgență
# Folosire: bash kill_switch.sh

echo "⚠️  KILL SWITCH ACTIVAT — Oprire toți agenții..."

for agent in alexandra gheorghe vasile dinu; do
    hermes gateway stop --profile "$agent" 2>&1
    echo "  -> $agent oprit"
done

echo "✅ Toți cei 4 agenți sunt inactivi."
echo "Pentru repornire, per agent: hermes gateway start --profile <nume>"
