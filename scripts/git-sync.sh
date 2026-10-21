#!/usr/bin/env bash
# Aligne la branche locale `travail` sur origin/main (lancé au démarrage de
# session par un hook). N'échoue jamais : en cas de doute, ne touche à rien et
# le dit.
#   - travail en retard            → avance rapide
#   - même contenu que origin/main → alignement (les MR ont tout fusionné)
#   - sinon                        → rebase ; annulé en cas de conflit
cd "$(dirname "$0")/.." || exit 0
# shellcheck disable=SC1091
source scripts/config.sh
T=${GIT_BRANCHE_TRAVAIL:-travail}; M=${GIT_BRANCHE_PRINCIPALE:-main}; D=${GIT_DISTANT:-origin}

info() { echo "Git atelier : $*"; }

[[ $(git branch --show-current) == "$T" ]] \
  || { info "branche courante « $(git branch --show-current) » (attendu : $T), pas de synchro."; exit 0; }
[[ -z $(git status --porcelain) ]] \
  || { info "modifications non commitées, pas de synchro."; exit 0; }
timeout 20 git fetch -q --prune "$D" 2>/dev/null \
  || { info "distant injoignable, pas de synchro."; exit 0; }

if [[ -z $(git rev-list "$D/$M..$T") ]]; then
  [[ -z $(git rev-list "$T..$D/$M") ]] && { info "$T à jour avec $M."; exit 0; }
  git merge -q --ff-only "$D/$M" && info "$T avancé sur $M ($(git rev-parse --short HEAD))."
elif git diff --quiet "$D/$M" "$T"; then
  git reset -q --keep "$D/$M" && info "$T aligné sur $M (tout est fusionné)."
elif git rebase -q "$D/$M" >/dev/null 2>&1; then
  info "$T rebasé sur $M ; $(git rev-list --count "$D/$M..$T") commit(s) non encore fusionné(s)."
else
  git rebase --abort 2>/dev/null
  info "rebase sur $M impossible sans conflit : $T laissé tel quel, à synchroniser à la main."
fi
exit 0
