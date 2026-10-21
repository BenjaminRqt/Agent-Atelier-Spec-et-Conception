---
name: sujet
description: Lister, ouvrir, créer, mettre en pause ou archiver les sujets (projets / features) de l'atelier. À utiliser quand l'utilisateur dit "/sujet", "mes sujets", "liste des sujets", "on passe sur X", "reprendre X", "nouveau sujet", "archiver X", ou demande où il en est.
argument-hint: "[slug | nouveau | pause <slug> | archiver <slug> | tous]"
---

# Sujets

Un sujet = un dossier `.atelier/sujets/<slug>/` **du projet cible** (configuré
dans `.env.local`) avec une fiche `sujet.md` (frontmatter
+ avancement + journal). Le sujet courant est mémorisé dans `.sujet-courant`
par `scripts/sujets.sh`. Toujours passer par ce script pour lister et
basculer.

## Selon l'argument

### Aucun argument ou `tous` — lister et choisir
1. `./scripts/sujets.sh liste` (ou `liste --tous` pour inclure les archivés).
2. Afficher le tableau tel quel (`*` = sujet courant).
3. Proposer avec AskUserQuestion : les 3 sujets actifs les plus récents
   (`maj`) + « Nouveau sujet ». Puis enchaîner sur « Ouvrir » ou « Nouveau ».

### `<slug>` (ou un bout de slug / de titre) — ouvrir
1. Retrouver le sujet (correspondance partielle sur slug ou titre ; si
   plusieurs, demander).
2. `./scripts/sujets.sh use <slug>`.
3. Lire `.atelier/sujets/<slug>/sujet.md`, le contexte `.atelier/contexte.md`, et le
   dernier livrable produit (fichier `0X-*.md` le plus avancé).
4. Répondre en 5 lignes max : où on en est, décisions clés, questions ouvertes
   bloquantes, **prochaine action**, skill suggérée.

### `nouveau` — créer
1. Demander (ou déduire du message) : titre, lien Jira/Notion éventuel. Si le
   projet n'a pas encore de `.atelier/contexte.md`, proposer de le créer depuis
   `templates/contexte.md`.
2. Slug court en kebab-case, unique dans `.atelier/sujets/`.
3. Créer `.atelier/sujets/<slug>/sujet.md` depuis `templates/sujet.md` (dates du jour).
4. `./scripts/sujets.sh use <slug>`, puis proposer `/cadrage`.

### `pause <slug>` / `archiver <slug>`
Passer `statut` à `pause` / `archive`, mettre à jour `maj`, ajouter une ligne
au journal. Si c'était le sujet courant, le dire.

## Règle commune à toutes les skills de l'atelier
À la fin de chaque étape (cadrage, spec…), mettre à jour la fiche du sujet
courant : `etape`, `maj`, case d'avancement, **Prochaine action**, décisions
clés, une ligne de journal, et les liens Jira/Notion/Miro créés. C'est ce qui
permet de reprendre un sujet à froid.
