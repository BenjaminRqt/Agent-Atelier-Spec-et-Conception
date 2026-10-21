---
name: publier
description: Publie (ou republie) les livrables du sujet courant dans Notion, avec schémas Miro, selon l'arborescence de l'atelier. Appelée par /spec et /conception ; à utiliser aussi quand l'utilisateur dit "/publier", "mets à jour Notion", "publie la spec".
argument-hint: "[cadrage | spec | conception | tout]"
---

# Publier dans Notion (+ Miro)

Le markdown local (`.atelier/sujets/<slug>/0X-*.md`) reste **la source de vérité**.
Notion en est la version lisible par un humain : on n'y recopie pas le
markdown, on le **met en page**.

## Arborescence Notion
```
<NOTION_RACINE_NOM>                     (racine : NOTION_RACINE_URL, configuration)
└── <Produit>                           (une page par contexte, retrouvée par son nom)
    └── <Projet / feature>              (sujet.md : champ notion ; avancement par lot)
        └── Lot <n> - <nom du lot>      (une page par lot, même s'il n'y en a qu'un)
            ├── 1. Cadrage
            ├── 2. Spec fonctionnelle   (page de synthèse)
            │   └── une sous-page par thème (modèle, droits, flux, migration,
            │       emails…)
            ├── 3. Conception           (synthèse + sous-pages par thème)
            └── 4. Découpage & chiffrage
```
- Créer ce qui manque (produit, feature) avec la même structure ; mettre à
  jour ce qui existe.
- Les identifiants de pages sont notés dans `.atelier/sujets/<slug>/publication.md`
  (livrable → page Notion → schémas Miro). Le lire avant de publier, le mettre
  à jour après.

## Navigation
- **Seule la fiche projet / feature a un sommaire** : « Plan du projet » en
  tête, liste imbriquée de mentions : lots → étapes → sous-pages (+ lien Jira
  du découpage). À mettre à jour à chaque création, suppression ou renommage
  de page.
- **Aucune autre page n'a de sommaire** : pas de
  « Dans ce lot », pas d'encadré « Pages de cette spec / conception », pas de
  ligne « Pages : … », ni de ligne `↩ <page parente>` : le fil d'Ariane de
  Notion suffit.

## Mise en page
- **Chaque page et sous-page commence par « Le principe »** : 2 à 5 phrases
  en prose (la page de synthèse : quelques paragraphes) qui expliquent l'idée
  de la partie avant tout tableau. Reprendre le texte de la section « Le
  principe » du livrable local.
- Lire `notion://docs/enhanced-markdown-spec` (via `fetch`) avant d'écrire.
- Page de synthèse : callout de statut (statut, version, date, fichier
  source), « en une phrase », schéma principal, acteurs.
- Sous-pages thématiques : parcours en listes numérotées ou colonnes, règles
  `RG-xx` en tableau, matrice des droits en tableau à en-tête de colonne,
  « Aujourd'hui → Demain » en tableau, critères d'acceptation en liste,
  avertissements en callouts (jaune = attention, rouge = sécurité, gris =
  contrainte technique, bleu = info).
- Pas de chemins de code dans le corps des pages de spec (réservés à la
  conception) ; un lecteur non développeur doit pouvoir suivre.
- Les tableaux ne contiennent que du texte enrichi (pas de listes).

## Schémas
- **Chaque spec et chaque conception a des schémas** (l'utilisateur les
  aime) : au minimum le modèle, et un flux pour chaque mécanisme non trivial
  (identité, droits, cycle de vie, séquence d'appels…).
- Créer les schémas dans le board Miro de l'équipe (`MIRO_BOARD_URL`), dans **un cadre par lot et
  par étape** (ex. « Lot 1 - Spec », « Lot 1 - Conception »), placé à côté des
  cadres existants sans les chevaucher. Mermaid via le widget diagram.
- Dans Notion, mettre **le même schéma en bloc ```mermaid** (rendu natif)
  suivi du lien « Ouvrir le schéma dans Miro » (`?moveToWidget=<id>`).
- En conception : diagrammes de séquence, ERD et composants sont attendus.

## Mise à jour d'une page existante
- `fetch` la page d'abord (nécessaire de toute façon), puis
  `./scripts/notion-etat.sh verifier <slug> <page_id> <page_last_edited_at>`.
  - `OK` : rien à signaler.
  - `MODIFIÉE` (code 3) : la page a été retouchée à la main depuis notre
    dernière écriture. Comparer le contenu du fetch au markdown local de la
    section concernée, **lister les retouches à l'utilisateur**, les reporter
    dans le markdown, et ne jamais réécrire un passage retouché (laisser le
    texte de l'utilisateur, adapter le nôtre autour).
  - `INCONNUE` (code 4) : page pas encore suivie, traiter comme `MODIFIÉE`.
- Après chaque série d'écritures, **un seul** appel pour toutes les pages
  touchées : `./scripts/notion-etat.sh marquer <slug> <page_id>...`. Pas de
  fetch de vérification ni de copie des pages : le coût reste celui du fetch
  déjà fait avant d'écrire.
- Écrire uniquement par `update_content` ciblé (passages précis) ; jamais de
  `replace_content` sur une page existante sans avoir montré la différence et
  obtenu l'accord. Ne jamais supprimer une sous-page sans accord explicite.
- Arguments multiples : passer les ids un par un ou via `xargs` (le shell est
  zsh, une variable non citée n'est pas découpée).

## Fin
Mettre à jour la fiche du sujet (champs `notion`, `miro`, journal) et
`publication.md`, puis donner à l'utilisateur le lien de la page de synthèse.
Pas de Jira ici : la création de tickets reste soumise à validation.
