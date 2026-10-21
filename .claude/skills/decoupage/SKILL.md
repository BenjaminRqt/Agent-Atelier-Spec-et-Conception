---
name: decoupage
description: Découpe la conception du sujet courant en epic et tickets Jira chiffrés (fourchettes en jours/homme), puis crée les tickets après validation. À utiliser quand l'utilisateur dit "/decoupage", "découpage", "créer les tickets", "on passe au découpage".
argument-hint: "[lot]"
---

# Découpage et tickets Jira

Objectif : un **epic par lot** et des tickets de **1 à 5 jours/homme** que
l'équipe peut prendre tels quels. Les devs connaissent leur métier : un ticket
dit **quoi** et **où regarder**, pas comment coder.

## Étapes
1. **Charger** le sujet courant : fiche, conception (doit être « prête »),
   spec, contexte (conventions de nommage du produit), configuration Jira.
2. **Regarder les conventions Jira du projet** (20 derniers tickets) : préfixe
   de titre, types utilisés, epics parents, forme des descriptions, champs
   réellement remplis. S'y conformer.
3. **Découper** dans `.atelier/sujets/<slug>/04-decoupage.md` (`04-decoupage-lotN.md`
   au-delà du lot 1) depuis
   `templates/decoupage.md` :
   - un ticket = un résultat livrable et testable (back + front ensemble si
     c'est la même fonctionnalité) ; type Story si visible par un utilisateur,
     Tâche si technique ;
   - pour chaque ticket : titre, type, RG couvertes, sections de conception,
     dépendances, fourchette optimiste / probable / pessimiste (j/h) ;
   - ordre de réalisation, tickets à **livrer ensemble**, total du lot ;
   - vérifier que chaque RG et chaque point de vigilance de la conception
     tombe dans un ticket.
4. **Relecture** par l'agent `avocat-du-diable` en mode découpage (couverture,
   dépendances, taille des tickets, risques de livraison).
5. **Valider avec l'utilisateur** : tableau récapitulatif (titre, type,
   fourchette) + nombre de tickets à créer. **Aucune création sans accord
   explicite dans le chat.**
6. **Vérifier le site et le projet Jira** de la configuration (`JIRA_SITE`,
   `JIRA_CLOUD_ID`, `JIRA_PROJET` via `./scripts/config.sh`) et que le
   connecteur y a accès : **ne jamais créer sur un autre site ni dans un autre
   projet / espace**, même si c'est le seul accessible ; si une clé est vide
   ou inaccessible, s'arrêter et le dire. Chercher aussi un **epic existant** du sujet
   avant d'en proposer un nouveau.
7. **Créer dans Jira** : l'epic, puis les tickets avec `parent` = epic.
   Description courte en markdown : contexte (1-2 lignes), à faire (puces),
   RG couvertes, liens Notion (spec et conception), estimation, dépendances.
   Pas de champ d'estimation si le projet n'en utilise pas.
8. **Reporter** les clés Jira dans `04-decoupage.md`, `sujet.md` (champ
   `jira` = epic) et `publication.md` ; ajouter une page « 4. Découpage &
   chiffrage » dans Notion si l'utilisateur le souhaite.
9. **Publier dans git** (`scripts/git-publier.sh sujet …`) et conclure avec le
   lien de l'epic.
