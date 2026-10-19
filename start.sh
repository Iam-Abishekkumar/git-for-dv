#!/usr/bin/env bash
# start.sh: build your practice sandbox in work/.
#
#   ./start.sh           build work/ (once)
#   ./start.sh --reset   delete work/ and build it fresh (your saved evidence and answers are kept)
#
# work/ holds a stand-in for the team's GitLab project (work/gitlab/fifo_dv.git) with the same
# history as the "Git for DV Engineers" guide. You practise inside work/. It is listed in
# .gitignore, so nothing in it is ever committed to your git-for-dv repo.

set -euo pipefail
ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
cd "$ROOT"
SAND="$ROOT/work"

command -v git >/dev/null || { echo "git is not installed:  sudo apt install git"; exit 1; }
if ! command -v iverilog >/dev/null; then
  echo "The exercises run real simulations with Icarus Verilog. Install it first:"
  echo "    sudo apt install iverilog"
  exit 1
fi

if [ -e "$SAND" ]; then
  if [ "${1:-}" = "--reset" ]; then
    rm -rf "$SAND"
  else
    echo "work/ already exists. To throw it away and start the sandbox again:"
    echo "    ./start.sh --reset      (your evidence and answers are kept)"
    exit 1
  fi
fi

# Ignore personal settings (signing, hooks, line endings) so the history matches the guide exactly.
G="git -c commit.gpgsign=false -c tag.gpgSign=false -c core.hooksPath=/dev/null -c core.autocrlf=false"

mkdir -p "$SAND/gitlab"
git init -q --bare "$SAND/gitlab/fifo_dv.git"
git -C "$SAND/gitlab/fifo_dv.git" symbolic-ref HEAD refs/heads/main
cp lab/post-receive "$SAND/gitlab/fifo_dv.git/hooks/post-receive"
chmod +x "$SAND/gitlab/fifo_dv.git/hooks/post-receive"

# Shortcuts so that, from inside work/fifo_dv, the scripts are one folder up: ../check.sh
for s in check.sh save.sh teammate.sh make_edits.sh; do ln -s "../$s" "$SAND/$s"; done
ln -s ../answers.txt "$SAND/answers.txt"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git init -q "$tmp/w"
cd "$tmp/w"
git symbolic-ref HEAD refs/heads/main

who() { export GIT_AUTHOR_NAME="$1" GIT_COMMITTER_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_COMMITTER_EMAIL="$2"; }
at()  { export GIT_AUTHOR_DATE="$1 +0530" GIT_COMMITTER_DATE="$1 +0530"; }
commit() {  # snapshot message
  cp -R "$ROOT/lab/$1/." .
  chmod +x scripts/run_test.sh 2>/dev/null || true
  $G add -A
  $G commit -q -m "$2"
}

# The team's history (simulated teammates). Same commits as the guide.
who "Priya Raman"   priya@example.com;   at 2026-10-12T10:00; commit c1 "rtl: add synchronous fifo"
who "Priya Raman"   priya@example.com;   at 2026-10-12T15:00; commit c2 "tb: add self-checking testbench with fifo_basic test"
who "Karthik S"     karthik@example.com; at 2026-10-13T11:00; commit c3 "scripts: add run_test.sh, testlist and .gitignore"
who "Abishek Kumar" abishek@example.com; at 2026-10-14T10:30; commit c4 "tb: add fifo_full test"
who "Abishek Kumar" abishek@example.com; at 2026-10-15T16:00; commit c5 "tb: add fifo_empty test"
who "Karthik S"     karthik@example.com; at 2026-10-15T23:30; $G tag -a nightly_pass_1015 -m "Nightly regression 15 Oct: 3/3 tests pass"
who "Karthik S"     karthik@example.com; at 2026-10-16T09:45; commit c6 "docs: add README with run instructions"
who "Priya Raman"   priya@example.com;   at 2026-10-16T14:20; commit c7 "rtl: simplify full flag logic"
who "Karthik S"     karthik@example.com; at 2026-10-17T11:10; commit c8 "scripts: record simulator version in each log"
who "Priya Raman"   priya@example.com;   at 2026-10-17T17:30; commit c9 "rtl: add port comments"
who "Karthik S"     karthik@example.com; at 2026-10-17T23:30; $G tag -a nightly_fail_1017 -m "Nightly regression 17 Oct: fifo_full FAIL"

$G push -q "$SAND/gitlab/fifo_dv.git" main --tags >/dev/null 2>&1
$G push -q "$SAND/gitlab/fifo_dv.git" main:release/a0 >/dev/null 2>&1
cd "$ROOT"

cat <<EOF
Sandbox ready in work/

  "GitLab" project : work/gitlab/fifo_dv.git
  history          : 9 commits, tags nightly_pass_1015 and nightly_fail_1017, branch release/a0

Next:  cat exercises/01_setup/README.md
EOF
