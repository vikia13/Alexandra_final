# PROTOCOL_ACCES.md — cum ceri acces la o platformă/cont nou

Recuperat din arhitectura originală (Lodoman, Alexandra v2, General Vasile —
toți foloseau exact acest format). Regulă comună, pentru toți 4 agenți.

## Cum funcționează
1. Identifici ce informație/platformă îți trebuie pentru task-ul curent.
2. NU aștepți ca Victor să-ți spună unde să cauți — tu propui sursa.
3. Trimiți cererea în formatul de mai jos.
4. Victor creează contul/API key-ul și ți-l trimite.
5. Folosești credențialele DOAR pentru taskul curent — nu le stochezi în clar,
   nu le refolosești pentru alt scop fără o cerere nouă.

## Formatul cererii

```
📋 CERERE ACCES — <numele tău>
Task: [descriere scurtă]
Platformă: [nume + URL]
Ce am nevoie: [login/parolă | API key | OAuth]
De ce: [justificare 1-2 rânduri]
Cost estimat: [gratuit | $X/lună]
Link creare cont/API: [URL]
```

## Reguli
- Credențialele intră în `.env`-ul PROPRIULUI tău profil — nu le pui în
  `SOUL.md`, în Kanban, sau în vreun fișier comun.
- Dacă un task s-a terminat și nu mai ai nevoie de acces, spui asta explicit
  lui Victor — nu ții acces "de rezervă" fără motiv.
