---
name: spec
description: Rédige la spec fonctionnelle du sujet courant à partir de son cadrage validé et du code existant. À utiliser quand l'utilisateur dit "/spec", "spec fonctionnelle", "spécifier", "on passe à la spec", ou après un cadrage validé.
argument-hint: "[lot ou périmètre à spécifier]"
---

# Spec fonctionnelle

Objectif : décrire **quoi** (comportements, règles, droits, cas limites,
critères d'acceptation) de façon assez précise pour concevoir, découper et
chiffrer sans revenir vers le métier. Pas de **comment** technique (c'est
`/conception`), mais ancré dans l'existant : on décrit les écarts par rapport
à ce qui marche aujourd'hui.

## Étapes

1. **Charger le sujet.** `./scripts/sujets.sh courant`. Lire `sujet.md`,
   `00-brief.md`, `01-cadrage.md`, le contexte du projet (`.atelier/contexte.md`) et
   les CLAUDE.md des dépôts listés. Si le cadrage n'est pas « validé » ou a des
   questions bloquantes ouvertes, le signaler et demander s'il faut continuer.
   Si l'argument précise un lot ou un périmètre, s'y limiter.

2. **Établir l'existant.** Pour chaque élément du périmètre du cadrage,
   retrouver dans le code (lecture seule) le comportement actuel : écrans,
   routes, règles métier, droits (voters), emails, données. Noter les
   fichiers. C'est la base des sections « Aujourd'hui → Demain ».
   Si un document externe est référencé (Miro, Notion, Jira), le lire via le
   connecteur.

3. **Rédiger** `.atelier/sujets/<slug>/02-spec.md` (`02-spec-lotN.md` au-delà du lot 1)
   depuis `templates/spec.md` :
   - **Le principe** en tête : quelques paragraphes en prose concise qui
     expliquent l'idée du projet sans détail (problème, solution, ce qui
     change pour chaque acteur, point d'attention), puis 2 à 5 phrases par
     thème. On doit comprendre le projet, ou une partie, **juste en lisant
     ces textes** ; les règles viennent ensuite pour le détail.
   - **Parcours** par acteur, numérotés, avec l'écran ou la route concernés.
   - **Règles de gestion** `RG-xx`, une règle = une phrase testable +
     un exemple. Ce sont elles que le découpage et les tests référenceront.
   - **Matrice des droits** (rôle × action → autorisé / refusé / périmètre)
     dès que le sujet touche à la sécurité ou à la visibilité.
   - **Aujourd'hui → Demain** pour chaque comportement existant modifié
     (c'est là que se cachent les régressions).
   - **Cas limites et erreurs** avec le message utilisateur attendu (en
     français).
   - **Migration / reprise de données** si le modèle change.
   - **Critères d'acceptation** en Given / When / Then, regroupés par RG.
   - **Traçabilité** : chaque décision et chaque élément de périmètre du
     cadrage pointe vers au moins une RG ou un parcours. Un élément non
     couvert = un trou à signaler.

4. **Questions.** Si des points bloquent la rédaction : un seul tour, max 5
   questions, chacune avec une proposition par défaut (AskUserQuestion pour
   les choix fermés). Le reste va en « Questions ouvertes » avec la
   proposition retenue par défaut, marquée comme hypothèse.

5. **Faire relire** par l'agent `avocat-du-diable` en mode spec (lui demander
   de vérifier la traçabilité cadrage → spec, la matrice des droits contre le
   code, et les régressions « Aujourd'hui → Demain »). Intégrer les remarques
   pertinentes, signaler les autres.

6. **Publier** dans Notion avec schémas Miro en suivant la skill `publier`
   (page de synthèse + une sous-page par thème ; au moins le schéma du modèle
   et un flux par mécanisme non trivial). Autorisé sans redemander (CLAUDE.md).

7. **Mettre à jour la fiche** du sujet (règle commune de la skill `sujet`) :
   case Spec, `etape: conception` si la spec est prête, prochaine action,
   décisions, journal.

8. **Conclure** en 3 lignes : maturité (prête pour conception / à
   clarifier), les décisions restantes, étape suivante (`/conception`), avec
   le lien Notion.

## Ne pas faire
- Pas de choix technique (tables, classes, endpoints nouveaux) : les noter
  comme « contrainte pour la conception » si le cadrage les impose.
- Ne pas recopier le cadrage : le référencer.
- Ne rien modifier dans les dépôts de code.
