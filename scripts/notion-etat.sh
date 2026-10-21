#!/usr/bin/env bash
# Repère les pages Notion modifiées par quelqu'un d'autre que l'atelier.
#
#   notion-etat.sh marquer  <slug> <page_id>...               après une écriture de l'atelier
#   notion-etat.sh verifier <slug> <page_id> <last_edited_at>  avant d'écrire (date du fetch)
#
# Fichier : <projet>/.atelier/sujets/<slug>/notion-etat.tsv — « page_id<TAB>date UTC de la
# dernière écriture de l'atelier ». Pas de copie des pages : le fetch fait de
# toute façon avant d'écrire donne `page_last_edited_at` ; s'il est postérieur
# à notre dernière écriture (+ marge), la page a été retouchée à la main.
# Code retour de `verifier` : 0 = rien à signaler, 3 = modifiée, 4 = inconnue.
set -euo pipefail

cmd=${1:?Usage : notion-etat.sh marquer|verifier <slug> …}
slug=${2:?slug manquant}
shift 2
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source scripts/config.sh
d="${ATELIER_BASE:?ATELIER_PROJET_DIR non configuré (.env.local)}/sujets/$slug"
f="$d/notion-etat.tsv"
[ -d "$d" ] || { echo "Sujet inconnu : $d" >&2; exit 1; }
touch "$f"
marge=120 # secondes : une écriture de l'atelier et le horodatage Notion ne tombent pas pile

norm() { tr -d '-' <<<"$1"; }

case $cmd in
  marquer)
    [ $# -ge 1 ] || { echo "page_id manquant" >&2; exit 1; }
    now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    for p in "$@"; do
      id=$(norm "$p")
      grep -v "^$id	" "$f" > "$f.tmp" || true
      printf '%s\t%s\n' "$id" "$now" >> "$f.tmp"
      sort "$f.tmp" > "$f"; rm -f "$f.tmp"
    done
    echo "Marqué : $# page(s) à $now"
    ;;
  verifier)
    id=$(norm "${1:?page_id manquant}")
    edited=${2:?last_edited_at manquant}
    ours=$(awk -F'\t' -v id="$id" '$1==id {print $2}' "$f")
    if [ -z "$ours" ]; then echo "INCONNUE : pas encore marquée"; exit 4; fi
    e=$(date -u -d "$edited" +%s); o=$(date -u -d "$ours" +%s)
    if [ $((e - o)) -gt $marge ]; then
      echo "MODIFIÉE à la main le $edited (dernière écriture atelier : $ours)"; exit 3
    fi
    echo "OK"
    ;;
  *) echo "Commande inconnue : $cmd" >&2; exit 1 ;;
esac
