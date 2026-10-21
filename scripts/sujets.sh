#!/usr/bin/env bash
# Gestion des sujets du projet cible (<projet>/.atelier/sujets/) : liste, sujet courant, bascule.
#   sujets.sh [liste [--tous]]   tableau des sujets (archivés masqués sans --tous)
#   sujets.sh courant            slug du sujet courant
#   sujets.sh use <slug>         bascule sur un sujet
#   sujets.sh contexte           projet, contexte et sujet courant (hook SessionStart)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/config.sh"
SUJETS="${ATELIER_BASE:+$ATELIER_BASE/sujets}"
COURANT="$ROOT/.sujet-courant"   # état personnel, non commité

# champ <fichier> <clé> : lit une clé du frontmatter YAML
champ() {
  sed -n '1,/^---$/{/^---$/d;p}' <(tail -n +2 "$1") | sed -n "s/^$2: *//p" | head -1
}

courant() { [[ -f $COURANT ]] && cat "$COURANT" || true; }

sans_projet() {
  echo "Atelier specs : aucun projet configuré (ATELIER_PROJET_DIR dans .env.local)."
  exit 0
}

case "${1:-liste}" in
  liste)
    [[ -n $SUJETS ]] || sans_projet
    actif=$(courant)
    fmt='%-1s %-30s %-14s %-9s %-10s %s\n'
    printf "$fmt" "" SUJET ETAPE STATUT JIRA MAJ
    for f in "$SUJETS"/*/sujet.md; do
      [[ -e $f ]] || { echo "(aucun sujet dans $SUJETS)"; exit 0; }
      slug=$(basename "$(dirname "$f")")
      statut=$(champ "$f" statut)
      [[ $statut == archive && ${2:-} != --tous ]] && continue
      mark=" "; [[ $slug == "$actif" ]] && mark="*"
      printf "$fmt" "$mark" "$slug" "$(champ "$f" etape)" \
        "$statut" "$(champ "$f" jira)" "$(champ "$f" maj)"
    done
    ;;
  courant)
    s=$(courant); echo "${s:-aucun}"
    ;;
  use)
    [[ -n $SUJETS ]] || sans_projet
    slug=${2:?Usage : sujets.sh use <slug>}
    [[ -f $SUJETS/$slug/sujet.md ]] || { echo "Sujet inconnu : $slug" >&2; exit 1; }
    echo "$slug" > "$COURANT"
    echo "Sujet courant : $slug"
    ;;
  contexte)
    [[ -n $SUJETS ]] || sans_projet
    echo "Atelier specs : projet $ATELIER_PROJET, dossier $ATELIER_BASE (contexte.md + sujets/)."
    s=$(courant)
    if [[ -z $s || ! -f $SUJETS/$s/sujet.md ]]; then
      echo "Aucun sujet courant dans ce projet. /sujet pour lister, ouvrir ou créer un sujet."
    else
      echo "Sujet courant = $s ($SUJETS/$s/). Fiche du sujet (journal : 5 dernières entrées) :"
      awk '/^## Journal/{j=1; print; next} !j{print} j && /^- [0-9]{4}-/{n++} j{buf[n]=buf[n] $0 "\n"} END{for(i=(n>5?n-4:1);i<=n;i++) printf "%s", buf[i]}' "$SUJETS/$s/sujet.md"
    fi
    ;;
  *)
    sed -n '2,6p' "$0" >&2; exit 1
    ;;
esac
