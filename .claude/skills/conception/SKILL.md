---
name: conception
description: Rédige la conception technique du sujet courant à partir de sa spec prête et du code existant, au niveau utile à l'équipe (BDD, endpoints, payloads, points de vigilance, menu et URLs front). À utiliser quand l'utilisateur dit "/conception", "conception technique", "on passe à la conception".
argument-hint: "[lot ou périmètre]"
---

# Conception technique

Objectif : donner à l'équipe **les décisions structurantes**, pas un plan
d'implémentation. Les devs connaissent leur métier et les conventions du
projet (CLAUDE.md des dépôts) : ne pas les réexpliquer.

## Niveau de détail attendu
**On commence par le principe** : quelques phrases en prose qui expliquent
l'approche technique retenue et pourquoi, avant les tableaux ; idem en tête
de chaque sous-page Notion.

**On présente :**
- **BDD** : tables et colonnes ajoutées / modifiées / supprimées, relations,
  contraintes importantes (unicité, nullabilité), reprise de données.
- **Endpoints** : méthode + URL, qui y a droit, payload et réponse en JSON
  d'exemple court (champs significatifs seulement). Endpoints modifiés :
  seulement ce qui change.
- **Changements majeurs** de comportement et **points de vigilance**
  (sécurité, régression, perf, cache, API externes, migration, déploiement).
- **Front** : structure du menu et URLs (routes ajoutées / modifiées), avec le
  rôle qui y accède. **Pas de design** ni de maquette.
- **Choix structurants** : seulement quand il y a un vrai choix, 2 options
  max + recommandation, en quelques lignes (ADR léger).

**On ne présente pas :** noms de classes une par une, signatures de méthodes,
découpage en fichiers, tests unitaires détaillés, CSS / composants, pseudo-code.
Si un détail est nécessaire pour comprendre un risque, une phrase suffit.

## Étapes
1. **Charger** le sujet courant : fiche, spec (doit être « prête »), cadrage,
   contexte, CLAUDE.md des dépôts. Se limiter au lot demandé.
2. **Lire le code existant** concerné (lecture seule) pour ancrer chaque
   proposition : modèle actuel, routes, sécurité, front (router, menu).
   Réutiliser l'existant (et le travail en cours s'il y en a) plutôt que
   réinventer.
3. **Rédiger** `.atelier/sujets/<slug>/03-conception.md` (`03-conception-lotN.md` au-delà
   du lot 1) depuis `templates/conception.md`. Chaque élément renvoie aux `RG-xx` qu'il sert.
   Viser **court** : une personne doit pouvoir le lire en 10 minutes.
4. **Questions** : un seul tour, max 3, uniquement pour un choix structurant
   impossible à trancher seul. Sinon : hypothèse notée.
5. **Relecture** par l'agent `avocat-du-diable` en mode conception.
6. **Publier** via la skill `publier` (synthèse + sous-pages : BDD, API,
   front ; **pas de page « Points de vigilance »** dans Notion, ils restent dans
   le markdown local) avec schémas : modèle de données (ERD) et un diagramme
   de séquence pour chaque flux non trivial.
7. **Mettre à jour la fiche** du sujet (`etape: decoupage` si prête).
8. **Conclure** en 3 lignes avec le lien Notion.

## Ne pas faire
- Ne rien modifier dans les dépôts de code.
- Ne pas re-spécifier : renvoyer aux RG de la spec.
