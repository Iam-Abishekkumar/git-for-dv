#!/usr/bin/env bash
# save.sh: save your progress to GitHub (the git-for-dv repo, NOT the sandbox).
#
#   ./save.sh "Solve 05: bisect"       (from the top folder)
#   ../save.sh "Solve 05: bisect"      (from inside work/fifo_dv)
#
# Runs ./check.sh (which saves evidence for newly passed exercises and updates the README),
# then commits everything in git-for-dv and pushes it.

set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
msg=${1:?usage: ./save.sh "Solve NN: what you did"}
cd "$ROOT"
./check.sh | tail -n 2
git add -A
if git diff --cached --quiet; then
  echo "Nothing new to save."
  exit 0
fi
git commit -q -m "$msg"
echo "Committed: $msg"
git push
