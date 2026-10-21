---
name: cadrage
description: Démarre un nouveau projet ou une nouvelle feature à partir d'un brief brut (notes, mail, transcription, ticket) et produit une fiche de cadrage. À utiliser quand l'utilisateur dit "nouveau projet", "nouvelle feature", "cadrage", "/cadrage" ou colle un brief à analyser.
---

# Cadrage

Objectif : transformer un brief flou en fiche de cadrage claire, en faisant
émerger ce qui manque **avant** d'écrire la moindre spec.

## Étapes

1. **Récupérer le brief.** Texte collé, fichier, page Notion ou ticket Jira
   (lire via le connecteur si un lien est fourni). Si rien n'est fourni,
   demander le brief.

2. **Choisir le sujet.** Si le sujet courant (`./scripts/sujets.sh courant`)
   correspond au brief et n'a pas encore de cadrage, l'utiliser. Sinon, créer
   un nouveau sujet comme décrit dans la skill `sujet` (section `nouveau`).
   Écrire `.atelier/sujets/<slug>/00-brief.md` avec le brief brut, tel quel.

3. **Analyser.** Extraire du brief :
   - problème / besoin réel (pas la solution demandée)
   - utilisateurs et parties prenantes
   - périmètre évoqué, contraintes, échéances
   - ce qui est **flou, contradictoire ou absent**

   Lire le contexte du projet (`.atelier/contexte.md`) et les CLAUDE.md des
   dépôts qu'il liste, puis repérer rapidement les zones du code concernées
   (pour poser de meilleures questions, pas pour concevoir). Signaler les
   pièges que le contexte décrit (ex. données venant d'API externes).

4. **Poser les questions.** Au maximum 8 questions, triées par impact, chacune
   avec *pourquoi elle compte* et, quand c'est possible, une **proposition de
   réponse par défaut** pour que l'utilisateur puisse juste valider.
   Utiliser AskUserQuestion pour les questions à choix fermés. Ne pas
   enchaîner plus de 2 tours de questions : le reste va en « Questions
   ouvertes ».

5. **Rédiger** `.atelier/sujets/<slug>/01-cadrage.md` (`01-cadrage-lotN.md` et
   `00-brief-lotN.md` pour un lot suivant) à partir de `templates/cadrage.md`.

6. **Faire relire** par l'agent `avocat-du-diable` (en mode cadrage) et
   intégrer ses remarques pertinentes ; signaler les autres à l'utilisateur.

7. **Mettre à jour la fiche** `.atelier/sujets/<slug>/sujet.md` (résumé, étape,
   avancement, prochaine action, décisions, journal, `maj`).

8. **Conclure** en 3 lignes : niveau de maturité (prêt pour spec / à clarifier),
   les 1-3 décisions à prendre, et l'étape suivante suggérée (`/spec`).

## Ne pas faire
- Ne pas proposer de solution technique à ce stade.
- Ne rien publier dans Notion/Jira sans demande explicite.
- Ne rien modifier dans les dépôts de code.
