#!/usr/bin/env bash
# Publie les modifications sur une branche dédiée et la pousse, sans checkout.
#
#   git-publier.sh outillage <description-kebab> "<Verbe à l'infinitif …>"
#   git-publier.sh sujet     <slug>              "<Verbe à l'infinitif …>" [TICKET-123]
#
# - outillage : dépôt de l'atelier (skills, agents, scripts, gabarits, docs…)
#     branche  outillage/AAAA-MM-JJ-<description>   message  outillage - <message>
#     Le même contenu est aussi commité sur la branche locale de travail.
# - sujet : dépôt du PROJET CIBLE (ATELIER_PROJET_DIR), seulement
#     <dossier>/sujets/<slug>/ et <dossier>/contexte.md (dossier : .atelier)
#     branche  atelier/<slug>/AAAA-MM-JJ             message  docs - <message> [- TICKET-123]
#     La branche courante et l'index du projet ne sont jamais touchés.
#
# Une seule branche ouverte par type (outillage) ou par sujet : tant qu'elle
# n'est pas fusionnée dans la branche principale du distant, elle est
# réutilisée, y compris depuis un autre poste (pas de flood de MR).
set -euo pipefail

type=${1:?Usage : git-publier.sh outillage|sujet <nom> "<message>" [ticket]}
nom=${2:?nom manquant}
msg=${3:?message manquant}
ticket=${4:-}
cd "$(dirname "$0")/.."
# shellcheck disable=SC1091
source scripts/config.sh
date=$(date +%F)

case $type in
  outillage)
    REPO=$PWD; D=${GIT_DISTANT:-origin}; M=${GIT_BRANCHE_PRINCIPALE:-main}; local_aussi=1; force=()
    # sujets/ et contextes/ : anciens emplacements (déplacés dans le projet cible).
    paths=(.claude scripts templates docs CLAUDE.md README.md .gitignore .env sujets contextes)
    motif="outillage/*"
    nouvelle="outillage/$date-$nom"
    titre="outillage - $msg"
    ;;
  sujet)
    [[ -n ${ATELIER_PROJET:-} ]] || { echo "ATELIER_PROJET_DIR non configuré (.env.local)" >&2; exit 1; }
    REPO=$ATELIER_PROJET; D=${PROJET_GIT_DISTANT:-origin}; M=${PROJET_GIT_BRANCHE_PRINCIPALE:-main}; local_aussi=0
    # -f : le dossier de l'atelier est exclu localement (.git/info/exclude).
    force=(-f)
    dossier=${ATELIER_DOSSIER:-.atelier}
    [[ -d $REPO/$dossier/sujets/$nom ]] || { echo "Sujet inconnu : $REPO/$dossier/sujets/$nom" >&2; exit 1; }
    paths=("$dossier/sujets/$nom" "$dossier/contexte.md")
    motif="atelier/$nom/*"
    nouvelle="atelier/$nom/$date"
    titre="docs - $msg"
    ;;
  *) echo "Type inconnu : $type (outillage|sujet)" >&2; exit 1 ;;
esac
g() { git -C "$REPO" "$@"; }
[[ -n $ticket ]] && titre="$titre - $ticket"
message="$titre

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"

g fetch -q --prune "$D"

# Branche ouverte = pas encore dans la branche principale et, si déjà poussée,
# toujours présente sur le distant (GitLab supprime la branche source à la fusion).
ouverte() {
  g merge-base --is-ancestor "$1" "$D/$M" && return 1
  if g config "branch.$1.remote" >/dev/null; then
    g rev-parse -q --verify "refs/remotes/$D/$1" >/dev/null || return 1
  fi
  return 0
}

branche=""
while read -r b; do
  [[ -n $b ]] && ouverte "$b" && { branche=$b; break; }
done < <(g for-each-ref --format='%(refname:short)' "refs/heads/$motif")

# Branche ouverte sur le distant mais absente en local (clone neuf, autre poste).
if [[ -z $branche ]]; then
  while read -r rb; do
    b=${rb#"$D"/}
    [[ -n $b ]] && ! g merge-base --is-ancestor "$rb" "$D/$M" && { g branch -q --track "$b" "$rb"; branche=$b; break; }
  done < <(g for-each-ref --format='%(refname:short)' "refs/remotes/$D/$motif")
fi

if [[ -z $branche ]]; then
  branche=$nouvelle; n=2
  while g rev-parse -q --verify "refs/heads/$branche" >/dev/null; do
    branche="$nouvelle-$n"; n=$((n + 1))
  done
  g branch -q --no-track "$branche" "$D/$M"
fi

# Chemins présents sur le disque ou suivis par la branche publiée : un chemin
# supprimé du disque mais encore dans la branche doit y être supprimé aussi.
tip=$(g rev-parse "refs/heads/$branche")
publies=()
for p in "${paths[@]}"; do
  if [[ -e $REPO/$p ]] || g cat-file -e "$tip:$p" 2>/dev/null; then publies+=("$p"); fi
done

# Commit sur la branche publiée via un index temporaire (aucun checkout).
# Sans -f pour l'outillage : les fichiers ignorés (.env.local,
# settings.local.json…) ne doivent jamais partir.
index=$(mktemp); trap 'rm -f "$index"' EXIT
GIT_INDEX_FILE=$index g read-tree "$tip"
[[ ${#publies[@]} -gt 0 ]] && GIT_INDEX_FILE=$index g add -A "${force[@]}" -- "${publies[@]}"
# Outillage : un fichier ignoré déjà publié par erreur est retiré de la branche.
if [[ ${#force[@]} -eq 0 ]]; then
  GIT_INDEX_FILE=$index g ls-files -ci --exclude-standard -z \
    | GIT_INDEX_FILE=$index xargs -0 -r git -C "$REPO" rm -q --cached --
fi
tree=$(GIT_INDEX_FILE=$index g write-tree)
if [[ $tree == "$(g rev-parse "$tip^{tree}")" ]]; then
  echo "Rien de nouveau à publier sur $branche."
else
  commit=$(g commit-tree "$tree" -p "$tip" -m "$message")
  g update-ref "refs/heads/$branche" "$commit" "$tip"
  echo "Commit $(g rev-parse --short "$commit") sur $branche : $titre"
fi

# Atelier seulement : même contenu commité sur la branche locale de travail.
if [[ $local_aussi == 1 ]]; then
  locaux=()
  for p in "${paths[@]}"; do
    if [[ -e $REPO/$p ]] || g ls-files --error-unmatch -- "$p" >/dev/null 2>&1; then locaux+=("$p"); fi
  done
  [[ ${#locaux[@]} -gt 0 ]] && g add -A -- "${locaux[@]}"
  g diff --cached --quiet || g commit -q -m "$message"
fi

g push -q -u "$D" "$branche"
echo "Poussée : $D/$branche ($(basename "$REPO"))"
