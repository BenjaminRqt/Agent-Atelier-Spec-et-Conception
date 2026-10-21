#!/usr/bin/env bash
# Configuration de l'équipe : .env (défauts commités) puis .env.local (non commité).
#
#   config.sh                 affiche la configuration (hook SessionStart)
#   config.sh get <CLE>       une valeur (ex. ATELIER_BASE : dossier .atelier du projet)
#   source scripts/config.sh  depuis un autre script : charge les variables
#
# Claude ne lit pas les fichiers .env* (permission refusée) : il passe par ce script.
_atelier_racine="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
set -a
# shellcheck disable=SC1091
[[ -f $_atelier_racine/.env ]] && source "$_atelier_racine/.env"
# shellcheck disable=SC1091
[[ -f $_atelier_racine/.env.local ]] && source "$_atelier_racine/.env.local"
# Projet cible : chemin absolu, et dossier de l'atelier dans ce projet.
_d="${ATELIER_PROJET_DIR-}"; ATELIER_PROJET="${_d/#\~/$HOME}"; unset _d
ATELIER_BASE="${ATELIER_PROJET:+$ATELIER_PROJET/${ATELIER_DOSSIER:-.atelier}}"
set +a

# Chargé par un autre script : on s'arrête là.
[[ ${BASH_SOURCE[0]} != "$0" ]] && return 0

case "${1:-afficher}" in
  get)
    v=${2:?Usage : config.sh get <CLE>}
    printf '%s\n' "${!v-}"
    ;;
  afficher)
    if [[ ! -f $_atelier_racine/.env.local ]]; then
      echo "Configuration de l'atelier : .env.local absent. Le créer à partir de .env (cp .env .env.local) et le remplir avant de travailler sur un projet."
      exit 0
    fi
    echo "Configuration de l'équipe (.env + .env.local) :"
    grep -hoE '^[A-Z_]+=' "$_atelier_racine/.env" | tr -d '=' | while read -r k; do
      printf '  %s=%s\n' "$k" "${!k-}"
    done
    if [[ -n $ATELIER_BASE ]]; then
      echo "  → dossier de l'atelier dans le projet : $ATELIER_BASE"
      [[ -d $ATELIER_PROJET ]] || echo "  ⚠ Projet introuvable : $ATELIER_PROJET"
      [[ -f $ATELIER_BASE/contexte.md ]] || echo "  ⚠ Pas de contexte : créer $ATELIER_BASE/contexte.md depuis templates/contexte.md"
    fi
    manque=$(for k in ATELIER_UTILISATEUR ATELIER_PROJET_DIR NOTION_RACINE_URL JIRA_SITE JIRA_PROJET; do [[ -z ${!k-} ]] && printf '%s ' "$k"; done)
    if [[ -n $manque ]]; then echo "  À renseigner dans .env.local : $manque"; fi
    ;;
  *) sed -n '2,8p' "$0" >&2; exit 1 ;;
esac
