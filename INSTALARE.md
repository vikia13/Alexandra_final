# INSTALARE — Proiectul Hermes pe 4 agenți

Urmează pașii EXACT în ordinea asta. Fiecare secțiune presupune că cea
anterioară a mers cu succes.

> **Notă importantă:** comenzile de mai jos sunt scrise pe baza documentației
> publice Hermes Agent. Înainte de pasul 3 (profiluri), rulează
> `hermes profile --help` și `hermes cron --help` pe server — dacă sintaxa
> exactă diferă la versiunea ta, spune-mi output-ul și ajustez comenzile.

---

## 0. Pregătire foldere de lucru

```bash
mkdir -p /home/victor/Desktop/Agents/{Alexandra,Gheorghe,Vasile,Dinu}
mkdir -p /home/victor/Desktop/Agents/trading_risk
mkdir -p /home/victor/Desktop/Agents/COMUN
```

Copiază fișierele din acest pachet:
```bash
cp COMUN/DESPRE_VICTOR.md      /home/victor/Desktop/Agents/COMUN/
cp COMUN/AUTONOMIE.md          /home/victor/Desktop/Agents/COMUN/
cp COMUN/PROTOCOL_ACCES.md     /home/victor/Desktop/Agents/COMUN/
cp trading_risk/risk_config.json /home/victor/Desktop/Agents/trading_risk/
```

Scripturile bash (folosite de cron `--script` mai jos) trebuie puse undeva
accesibil fiecărui profil — cel mai simplu, un folder comun în PATH:
```bash
mkdir -p /home/victor/Desktop/Agents/scripts
cp scripts/health-monitor.sh /home/victor/Desktop/Agents/scripts/
cp scripts/cross_audit.sh    /home/victor/Desktop/Agents/scripts/
cp scripts/kill_switch.sh    /home/victor/Desktop/Agents/scripts/
chmod +x /home/victor/Desktop/Agents/scripts/*.sh
```
> Dacă `hermes cron create --script` cere calea completă în loc de doar
> numele fișierului, folosește `/home/victor/Desktop/Agents/scripts/health-monitor.sh`
> în comenzile de mai jos, în loc de `health-monitor.sh`.

---

## 1. Instalare Hermes (dacă nu e deja instalat)

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

---

## 2. Creare profiluri

```bash
hermes profile create alexandra
hermes profile create gheorghe
hermes profile create vasile
hermes profile create dinu

# Descrierea fiecarui profil — folosita de Kanban pentru a ruta task-urile
# automat catre agentul potrivit (nu e o cheie in config.yaml, e comanda separata)
alexandra description "Orchestrator: coordoneaza echipa prin Kanban, valideaza, audit saptamanal. Nu executa detalii."
gheorghe description "Dezvoltator: scrie, testeaza si finalizeaza cod. Domeniu: AI_TRADING_OS si AI_screener."
vasile description "Analist financiar si strategic: piete, tendinte macro, crypto, fonduri europene."
dinu description "Cercetare probabilistica: loterii (EV, onestitate statistica) si analiza strategica pentru echipa."
```

## 3. Configurare model + chei API, per profil

```bash
alexandra setup   # alege DeepSeek, model deepseek-v4-pro
gheorghe setup    # alege Xiaomi/MiMo, model mimo-v2.5-pro
vasile setup      # alege DeepSeek, model deepseek-v4-pro
dinu setup        # alege DeepSeek, model deepseek-v4-flash
```

## 4. Copiază config.yaml și SOUL.md în fiecare profil

Locația exactă a folderului de profil poate diferi ușor între versiuni —
verifică cu `hermes profile show alexandra` (sau echivalent) ce cale de config
folosește, apoi:

```bash
cp Alexandra/config.yaml   <cale_profil_alexandra>/config.yaml
cp Alexandra/SOUL.md       <cale_profil_alexandra>/SOUL.md

cp Gheorghe/config.yaml    <cale_profil_gheorghe>/config.yaml
cp Gheorghe/SOUL.md        <cale_profil_gheorghe>/SOUL.md

cp Vasile/config.yaml      <cale_profil_vasile>/config.yaml
cp Vasile/SOUL.md          <cale_profil_vasile>/SOUL.md

cp Dinu/config.yaml        <cale_profil_dinu>/config.yaml
cp Dinu/SOUL.md            <cale_profil_dinu>/SOUL.md
```

## 5. Memoria comună — symlink în fiecare folder de agent

```bash
ln -s /home/victor/Desktop/Agents/COMUN/DESPRE_VICTOR.md /home/victor/Desktop/Agents/Alexandra/USER.md
ln -s /home/victor/Desktop/Agents/COMUN/DESPRE_VICTOR.md /home/victor/Desktop/Agents/Gheorghe/USER.md
ln -s /home/victor/Desktop/Agents/COMUN/DESPRE_VICTOR.md /home/victor/Desktop/Agents/Vasile/USER.md
ln -s /home/victor/Desktop/Agents/COMUN/DESPRE_VICTOR.md /home/victor/Desktop/Agents/Dinu/USER.md
```

## 6. Permisiuni — izolare reală la nivel de Linux

```bash
# Creezi câte un utilizator de sistem per agent (fără shell de login)
sudo useradd -r -s /usr/sbin/nologin agent-alexandra
sudo useradd -r -s /usr/sbin/nologin agent-gheorghe
sudo useradd -r -s /usr/sbin/nologin agent-vasile
sudo useradd -r -s /usr/sbin/nologin agent-dinu

# Fiecare folder apartine agentului lui, doar el poate scrie
sudo chown -R agent-alexandra:agent-alexandra /home/victor/Desktop/Agents/Alexandra
sudo chown -R agent-gheorghe:agent-gheorghe   /home/victor/Desktop/Agents/Gheorghe
sudo chown -R agent-vasile:agent-vasile       /home/victor/Desktop/Agents/Vasile
sudo chown -R agent-dinu:agent-dinu           /home/victor/Desktop/Agents/Dinu
sudo chmod -R 750 /home/victor/Desktop/Agents/{Alexandra,Gheorghe,Vasile,Dinu}

# Alexandra are nevoie de CITIRE (nu scriere) la celelalte 3, pentru audit
sudo usermod -aG agent-gheorghe agent-alexandra
sudo usermod -aG agent-vasile   agent-alexandra
sudo usermod -aG agent-dinu     agent-alexandra

# Dinu are nevoie de CITIRE (nu scriere) la Vasile si Gheorghe, pentru Modulul 2
# (analiza strategica) - vezi Dinu/SOUL.md
sudo usermod -aG agent-vasile   agent-dinu
sudo usermod -aG agent-gheorghe agent-dinu

# Nota: dupa usermod -aG, grupurile noi se aplica la urmatorul login/restart
# al serviciului agentului respectiv, nu instant.

# Victor (tu) ai acces la tot, indiferent de asta, fiind owner/sudo
```

## 7. Gateway Telegram — câte un bot separat, per profil

```bash
# Configureaza platforma de mesagerie (Telegram) INAINTE de a instala serviciul permanent
alexandra gateway setup      # alege Telegram, introdu tokenul botului Alexandra
gheorghe gateway setup       # tokenul botului Gheorghe
vasile gateway setup         # tokenul botului Vasile
dinu gateway setup           # tokenul botului Dinu

# Instaleaza fiecare gateway ca serviciu permanent (systemd pe Linux)
alexandra gateway install    # creeaza serviciul hermes-gateway-alexandra
gheorghe gateway install     # creeaza serviciul hermes-gateway-gheorghe
vasile gateway install       # creeaza serviciul hermes-gateway-vasile
dinu gateway install         # creeaza serviciul hermes-gateway-dinu
```

## 8. Kanban — 2 board-uri separate

```bash
alexandra kanban init
alexandra kanban boards create echipa  --name "Echipa Agenti"
alexandra kanban boards create trading --name "AI Trading OS + Screener"
```

## 9. Cron jobs

```bash
# --- Alexandra ---
alexandra cron create "every 15m" --no-agent --script health-monitor.sh \
  --deliver telegram --name "health-monitor-alexandra"

alexandra cron create "0 18 * * 0" \
  "Fa auditul saptamanal: Kanban (task-uri finalizate vs restante per agent), \
  cron (rata succes/esec per agent), cost API per agent vs buget zilnic, \
  activitate reala in foldere. Propune schimbari. Trimite raportul." \
  --deliver telegram --name "raport-saptamanal-alexandra"

# --- Gheorghe ---
gheorghe cron create "every 15m" --no-agent --script health-monitor.sh \
  --deliver telegram --name "health-monitor-gheorghe"

gheorghe cron create "0 0 * * 1-6" \
  "Verifica daca ai proiecte de lucru in folderul tau. Daca da, lucreaza direct \
  pe ele acum, in aceasta sesiune. Daca nu gasesti nimic de lucru, opreste-te \
  imediat." \
  --workdir /home/victor/Desktop/Agents/Gheorghe \
  --max-turns 40 \
  --name "lucru-noapte-gheorghe"
# Notă: seteaza in config.yaml sau flag dedicat durata maxima sesiune ~5h (00:00-05:00)

# --- Vasile ---
vasile cron create "every 15m" --no-agent --script health-monitor.sh \
  --deliver telegram --name "health-monitor-vasile"

vasile cron create "10 3 * * 1-5" \
  "Analizeaza pietele (actiuni, crypto pe Binance/Bybit/KuCoin/CoinGecko), cauta \
  tendinte macro tematice, verifica ipoteze de tip 'unde va curge capitalul masiv'. \
  Foloseste date reale, nu presupuneri." \
  --workdir /home/victor/Desktop/Agents/Vasile \
  --name "analiza-noapte-vasile"

vasile cron create "0 9 * * 1-6" \
  "Rezuma pe scurt ce ai gasit peste noapte. Pune intrebari daca ai nevoie de o decizie." \
  --deliver telegram --name "raport-zilnic-vasile"

vasile cron create "0 9 * * 0" \
  "Raport strategic saptamanal: intrebari pe termen lung, ipoteze de urmarit \
  in timp pentru un plan strategic indelungat." \
  --deliver telegram --name "raport-strategic-vasile"

# --- Dinu ---
dinu cron create "every 15m" --no-agent --script health-monitor.sh \
  --deliver telegram --name "health-monitor-dinu"

dinu cron create "0 1 * * 6" \
  "Cauta loterii disponibile (EuroMillions si altele). Calculeaza EV real \
  (jackpot/pret bilet/sansa). Respecta regula de onestitate statistica din SOUL.md. \
  Pune pe lista de lucru saptamanala ce merita urmarit." \
  --workdir /home/victor/Desktop/Agents/Dinu \
  --name "cercetare-sambata-dinu"

dinu cron create "0 1 * * 1" \
  "Analizeaza folderul tau, vezi ce ai lasat neterminat. Cauta informatie noua. \
  Respecta regula de onestitate statistica din SOUL.md." \
  --workdir /home/victor/Desktop/Agents/Dinu \
  --name "cercetare-luni-dinu"

dinu cron create "0 11 * * 2" \
  "Trimite raportul EuroMillions: EV actualizat + 3 combinatii, etichetate \
  corect conform regulii de onestitate statistica din SOUL.md." \
  --deliver telegram --name "raport-euromillions-dinu"
# Notă: ajusteaza ziua saptamanii (acum marti, exemplu) la ziua reala de extragere

# --- Cross-audit (Alexandra, la fiecare ora) — verifica daca AGENTII raspund,
# nu doar daca serverul e sanatos (diferit de health-monitor.sh) ---
alexandra cron create "0 * * * *" --no-agent --script cross_audit.sh \
  --deliver telegram --name "cross-audit-alexandra"

---

## Kill switch — oprire de urgență

Dacă ceva nu merge bine și vrei să oprești toți cei 4 agenți imediat:

```bash
bash scripts/kill_switch.sh
```

Pentru repornire, per agent: `hermes gateway start --profile <nume>`
```

---

## Verificare finală

```bash
alexandra kanban list
alexandra cron list
gheorghe cron list
vasile cron list
dinu cron list
```

Toate cele 4 profiluri trebuie să apară active, cu job-urile de mai sus listate.

---

## Testul de permisiuni — confirmă izolarea reală (idee de la Qwen)

Rulează, ca utilizatorul sub care ar rula procesul Alexandrei:

```bash
sudo -u agent-alexandra touch /home/victor/Desktop/Agents/Gheorghe/test.txt
```

**Rezultat corect:** `Permission denied`. Dacă fișierul chiar se creează, permisiunile
de la pasul 6 nu sunt aplicate corect — verifică `chown`/`chmod` din nou înainte
să continui.

## Testul de foc — confirmă că agenții chiar răspund, nu inventează (idee de la Qwen)

Scrie-i Alexandrei pe Telegram:
> "Cere-i lui Vasile prețul actual EUR/USD și lui Dinu probabilitatea la o
> întrebare simplă, apoi spune-mi exact ce ți-au răspuns ei."

- **Succes:** Alexandra creează task-uri pe Kanban pentru Vasile și Dinu,
  așteaptă, și îți transmite exact ce au raportat ei.
- **Eșec:** Alexandra îți dă ea un preț/o probabilitate inventată, fără să-i
  fi întrebat cu adevărat. Dacă se întâmplă asta, întărim interdicția din
  `SOUL.md` al Alexandrei — spune-mi și ajustez fișierul.
