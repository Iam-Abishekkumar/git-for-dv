#!/usr/bin/env bash
# teammate.sh: what your teammates do on "GitLab" during the lab.
#
#   ../teammate.sh merge <branch>      Karthik reviews your Merge Request and merges it into main.
#                                     Like a real CI gate, he only merges if the whole regression passes.
#   ../teammate.sh push-reset-test     Karthik pushes a new test (fifo_reset) to main  (exercise 11)

set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
ORIGIN="$ROOT/work/gitlab/fifo_dv.git"
[ -d "$ORIGIN" ] || { echo "Run ./start.sh first (in the top folder of git-for-dv)."; exit 1; }
G="git -c commit.gpgsign=false -c core.hooksPath=/dev/null"

export GIT_AUTHOR_NAME="Karthik S" GIT_COMMITTER_NAME="Karthik S"
export GIT_AUTHOR_EMAIL="karthik@example.com" GIT_COMMITTER_EMAIL="karthik@example.com"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git clone -q "$ORIGIN" "$tmp/w" 2>/dev/null
cd "$tmp/w"

regression() {
  local fail=0
  for t in $(cat tests/testlist); do scripts/run_test.sh "$t" | sed 's/^/    /' || fail=1; done
  return $fail
}

case "${1:-}" in
  merge)
    b=${2:?usage: ../teammate.sh merge <branch>}
    git rev-parse -q --verify "origin/$b" >/dev/null || { echo "Branch '$b' is not on GitLab. Push it first:  git push -u origin $b"; exit 1; }
    if git merge-base --is-ancestor "origin/$b" HEAD; then echo "'$b' has nothing new to merge: everything on it is already in main."; exit 0; fi
    echo "Karthik: reviewing '$b' ..."
    if ! $G merge -q --no-ff "origin/$b" -m "Merge branch '$b' into 'main'" >/dev/null 2>&1; then
      echo "Karthik: '$b' conflicts with main. Merge origin/main into your branch, fix it, push again."
      exit 1
    fi
    echo "Pipeline (full regression on the merged result):"
    if regression; then
      $G push -q origin main >/dev/null 2>&1
      echo "Karthik: pipeline passed. Merged '$b' into main."
    else
      echo "Karthik: pipeline FAILED, so the merge request was NOT merged. Fix your branch and push again."
      exit 1
    fi
    ;;
  push-reset-test)
    if grep -qx fifo_reset tests/testlist; then echo "Karthik already pushed fifo_reset."; exit 0; fi
    awk -v blk="$ROOT/lab/blocks/reset.sv" '
      index($0, "\"fifo_basic\": begin") && !done { while ((getline l < blk) > 0) print l; done = 1 }
      { print }' tb/tb_fifo.sv > tb/tb_fifo.sv.new && mv tb/tb_fifo.sv.new tb/tb_fifo.sv
    echo fifo_reset >> tests/testlist
    $G commit -q -am "tb: add fifo_reset test"
    $G push -q origin main >/dev/null 2>&1
    echo "Karthik: pushed 'tb: add fifo_reset test' to main (it adds fifo_reset to tests/testlist)."
    ;;
  *)
    sed -n '2,8p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
    ;;
esac
