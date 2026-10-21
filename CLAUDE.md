# Atelier specs

Espace de travail pour produire specs, conceptions techniques, découpages,
chiffrages et présentations, sur **plusieurs sujets en parallèle**. Claude est
un binôme : il propose, l'humain tranche.

## Configuration de l'équipe
L'atelier sert à n'importe quelle équipe. Ce qui lui est propre est dans
`.env.local` (non commité ; liste des clés et valeurs par défaut dans `.env`),
injecté au démarrage par `./scripts/config.sh` : qui utilise l'atelier
(`ATELIER_UTILISATEUR`, `ATELIER_ROLE`, `ATELIER_EQUIPE`), pour qui on écrit
(`ATELIER_DESTINATAIRES`), la racine Notion (`NOTION_RACINE_URL`), le site et
le projet Jira (`JIRA_SITE`, `JIRA_CLOUD_ID`, `JIRA_PROJET`, `JIRA_BOARD`), le
board Miro (`MIRO_BOARD_URL`), Figma, les branches git.
- Ne jamais lire `.env*` (permission refusée) : relire la configuration avec
  `./scripts/config.sh` ou `./scripts/config.sh get <CLE>`.
- Si une clé utile est vide, le dire et demander la valeur ; ne pas publier
  dans un outil non configuré.
- Le projet cible est ouvert dans `.claude/settings.local.json` (non commité,
  modèle : `.claude/settings.local.json.example`) : lecture du code, écriture
  **seulement** dans son dossier `.atelier/`.

Écrire pour les destinataires configurés : des devs qui connaissent le code,
aller droit au but, pas de vulgarisation. Les fichiers de code se citent dans
le markdown local et en conception ; une page Notion de spec reste lisible par
le PO.

## Organisation : l'atelier et le projet cible
L'atelier ne contient que l'outillage (règles, skills, scripts, gabarits). Les
données d'un projet vivent **dans le projet cible** (`ATELIER_PROJET_DIR`,
configuration), dans le dossier `.atelier/` (`./scripts/config.sh get
ATELIER_BASE` pour le chemin absolu). Dans les skills, les chemins `.atelier/…`
sont relatifs à ce projet.
- **Contexte** (`.atelier/contexte.md`) : ce qu'il faut savoir du produit —
  dépôts de code, équipe, glossaire, pièges, conventions. Partagé par tous les
  sujets du projet. Nouveau projet : copier `templates/contexte.md`.
- **Sujet** (`.atelier/sujets/<slug>/`) : un projet ou une feature. Fiche
  `sujet.md` (frontmatter : étape, statut, liens ; avancement ; prochaine
  action ; journal) + un fichier par étape, suffixé par lot au-delà du
  premier (`02-spec.md` pour le lot 1, `02-spec-lot2.md` pour le lot 2),
  `publication.md` (pages Notion, schémas Miro, tickets Jira) et
  `notion-etat.tsv` (suivi des retouches Notion, voir skill `publier`).
- **Sujet courant** : mémorisé dans `.sujet-courant` (atelier, non commité),
  injecté au démarrage de session par un hook. `/sujet` pour lister / ouvrir
  / créer / archiver.

Avant de travailler sur un sujet : lire sa fiche **et** le contexte du projet
(et les CLAUDE.md des dépôts qu'il liste). Si aucun sujet n'est courant et que
la demande en concerne un, proposer `/sujet`.

## Notion
Racine : `NOTION_RACINE_URL` (configuration) → produit → projet / feature →
lot → étape.
Arborescence, mise en page et suivi des retouches : skill `publier`.

## Git
Les modifications partent sur des branches dédiées, via
`./scripts/git-publier.sh`, **à la fin de chaque demande** qui a modifié des
fichiers (un commit par demande, pas par fichier). Le script commite sans
checkout : la branche courante et l'index du projet cible ne sont jamais
touchés.

| Type | Dépôt | Quoi | Branche | Message (= titre de MR) |
|---|---|---|---|---|
| **outillage** | atelier | `.claude/`, `scripts/`, `templates/`, `docs/`, `CLAUDE.md`, `README.md`, `.env` | `outillage/AAAA-MM-JJ-<description>` | `outillage - <Verbe à l'infinitif …>` |
| **sujet** | projet cible | `.atelier/sujets/<slug>/`, `.atelier/contexte.md` | `atelier/<slug>/AAAA-MM-JJ` | `docs - <Verbe à l'infinitif …> [- <ticket Jira>]` |

- Une demande qui touche les deux types → deux appels (outillage puis sujet).
- **Pas de flood** : tant que la branche du type (ou du sujet) n'est pas
  fusionnée, le script la réutilise, même depuis un autre poste ; une
  nouvelle n'est créée qu'après fusion.
- Ne jamais forcer un push, ni pousser une branche principale ou la branche
  de travail de l'atelier.
- **Atelier** : distant `GIT_DISTANT`, branche principale
  `GIT_BRANCHE_PRINCIPALE`, branche locale de travail `GIT_BRANCHE_TRAVAIL`
  (par défaut `origin`, `main`, `travail`), jamais poussée. **Synchro
  automatique** au démarrage (hook → `scripts/git-sync.sh`) : la branche de
  travail est avancée, alignée ou rebasée sur la branche principale, jamais de
  commit de merge. Si le script signale un conflit, une branche inattendue ou
  des modifications non commitées, le dire avant de continuer.
- **Projet cible** : distant `PROJET_GIT_DISTANT`, branche principale
  `PROJET_GIT_BRANCHE_PRINCIPALE` (par défaut `origin`, `main`). `.atelier/`
  est exclu localement (`.git/info/exclude`) pour ne pas apparaître dans le
  statut de la branche de dev.

## Dépôts de code
L'atelier ne fait **que lire** le code des dépôts listés dans le contexte :
aucune modification **hors du dossier `.atelier/`**, aucune commande
`docker`, `make`, `bin/console`, ni rien qui touche la qualif/prod. Respecter les interdits de leurs CLAUDE.md (secrets,
`.env*`…).

## Workflow d'un sujet
Chaque étape lit les fichiers des étapes précédentes, puis met à jour la fiche
du sujet (étape, maj, avancement, prochaine action, journal).

| Étape | Skill | Fichier produit |
|---|---|---|
| 1. Cadrage | `/cadrage` | `00-brief.md`, `01-cadrage.md` |
| 2. Spec fonctionnelle | `/spec` | `02-spec.md` |
| 3. Conception | `/conception` | `03-conception.md` + `adr/` |
| 4. Découpage et chiffrage | `/decoupage` | `04-decoupage.md` + tickets Jira |
| 5. Présentation | sur demande | `presentation.html`, publiée en artefact |

Présentation : orientée **métier** (pour chaque lot : le métier, ce qui
change pour chacun, la conception, puis les solutions techniques avec API et
schémas), un lien Notion par diapositive ; pas de découpage, de chiffrage ni
de questions ouvertes, sauf demande.

## Règles
- **Brouillon local d'abord.** Tout est écrit en markdown dans
  `.atelier/sujets/`, qui reste la source de vérité.
- **Notion + Miro alimentés aux étapes spec et conception** (autorisation
  permanente) : à la fin de `/spec` et `/conception`, publier via la skill
  `publier` — pages lisibles par un humain, **avec des schémas**. Ailleurs,
  publier seulement sur demande.
- **Jira** : jamais de création ni de modification de ticket sans validation
  explicite dans le chat, et **uniquement dans `JIRA_SITE` / `JIRA_PROJET`**
  (configuration), même si le connecteur donne accès à d'autres sites ou
  projets.
- **Supprimer une règle, c'est l'effacer partout** : la
  règle et tout ce qui en dépend (parcours, cas limites, critères, routes,
  payloads, tickets du découpage, traçabilité) disparaissent du markdown, de
  Notion et de Miro. Pas de ligne « Supprimée », pas de note « retiré le… »,
  numéro non réutilisé. La trace reste dans le journal de `sujet.md` et dans
  git. Jira : ne rien toucher sans accord, mais signaler les tickets concernés.
- **Ne pas inventer.** Une info manquante devient une question ouverte, jamais
  une hypothèse silencieuse. Les hypothèses assumées sont listées comme telles.
- **Ancrer dans le code.** Pour toute conception, lire le code existant avant de
  proposer ; citer les fichiers concernés.
- **Options seulement pour les vrais choix.** En conception, 2 options max
  avec compromis et une recommandation (ADR léger) ; une décision qui engage
  l'équipe peut faire l'objet d'un ADR complet (`adr/`, gabarit `adr.md`).
- **Chiffrage en fourchette** (optimiste / probable / pessimiste) avec hypothèses
  et risques. Unité : **jours/homme**.
- Ne jamais mélanger deux sujets : un fichier écrit va dans le dossier du sujet
  courant.
- **Vocabulaire métier** : n'employer que les termes du glossaire du contexte
  (termes métier dans la prose, termes techniques réservés aux noms de tables
  et de classes).
- Langue : français. Ton : direct, concis, pas de remplissage.
- Utiliser les gabarits de `templates/`.
