#!/usr/bin/env bash
# check.sh: scoreboard for git-for-dv.
#
#   ./check.sh        check your sandbox (work/) live. The FIRST time an exercise passes, its evidence
#                     is saved in exercises/NN_*/evidence/ (commit it!) and the README table is updated.
#   ./check.sh --ci   verify only the saved evidence. This is what GitHub Actions runs on every push.
#
# Exit code (--ci): 1 if any saved evidence fails. Unsolved exercises never fail.

set -u
ROOT=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
cd "$ROOT"
SAND="$ROOT/work"; ORIGIN="$SAND/gitlab/fifo_dv.git"; R="$SAND/fifo_dv"
BAD=7c75b5683bae828612c7410ce507d908d7ae3d74    # the commit that broke fifo_full (fixed in the lab history)
MODE=local
[ "${1:-}" = "--ci" ] && MODE=ci

# work/answers.txt is a link to answers.txt. Some tools (like sed -i) replace the link with a copy:
# if that happened, take the copy back so your answers are saved.
if [ $MODE = local ] && [ -f "$SAND/answers.txt" ] && [ ! -L "$SAND/answers.txt" ]; then
  cp "$SAND/answers.txt" "$ROOT/answers.txt" && rm "$SAND/answers.txt" && ln -s ../answers.txt "$SAND/answers.txt"
  echo "(work/answers.txt had become a separate copy: your answers are now back in answers.txt)"
fi
if [ "$MODE" = local ] && [ ! -d "$ORIGIN" ]; then
  echo "(no sandbox in work/ yet: checking saved evidence only. Run ./start.sh to practise.)"
  MODE=ci
fi

if [ -t 1 ] || [ -n "${CI:-}" ]; then G=$'\e[32m'; RD=$'\e[31m'; Y=$'\e[33m'; D=$'\e[2m'; B=$'\e[1m'; N=$'\e[0m'
else G=; RD=; Y=; D=; B=; N=; fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# ---------------------------------------------------------------- helpers on a clone of "GitLab" in $O
O=""
OG()       { git -C "$O" "$@"; }
has()      { OG rev-parse -q --verify "$1" >/dev/null 2>&1; }
contains() { OG merge-base --is-ancestor "$1" "$2" 2>/dev/null; }   # is $1 inside $2's history?
run_at() {   # ref test...  -> 0 if every test passes at ref
  local ref=$1; shift
  ( cd "$O" && git checkout -q --detach "$ref" 2>/dev/null || exit 1
    for t in "$@"; do scripts/run_test.sh "$t" >/dev/null 2>&1 || exit 1; done )
}
all_at() { run_at "$1" $(OG show "$1:tests/testlist" 2>/dev/null); }
ans()    { sed -n "s/^$1=//p" "$ROOT/answers.txt" 2>/dev/null | head -n 1 | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'; }

LIVE=""
live_origin()   { [ -n "$LIVE" ] || { LIVE="$tmp/live"; git clone -q "$ORIGIN" "$LIVE" 2>/dev/null; }; O=$LIVE; }
bundle_origin() { local d; d=$(mktemp -d "$tmp/b.XXXX"); git clone -q "$1" "$d/r" 2>/dev/null || return 1; O="$d/r"; }

# ---------------------------------------------------------------- the checks (set ST and MSG)
c07() { local F=origin/fix/fifo_full_flag
  if ! has $F; then ST=TODO; MSG="push a branch named fix/fifo_full_flag"
  elif ! contains nightly_fail_1017 $F; then ST=FAIL; MSG="start the branch from main"
  elif run_at $F fifo_full; then ST=PASS; MSG=""
    OG log --format=%B "nightly_fail_1017..$F" | grep -q "This reverts commit $BAD" || MSG="works; next time try git revert, the cleanest way to undo a commit"
  else ST=FAIL; MSG="fifo_full still fails on your pushed branch"; fi; }
c08() { local F=origin/fix/fifo_full_flag
  if has $F && contains $F origin/main && run_at origin/main fifo_full; then ST=PASS; MSG=""
  else ST=TODO; MSG="../teammate.sh merge fix/fifo_full_flag"; fi; }
c09() { local T=origin/tb/fifo_overflow_test
  if ! has $T; then ST=TODO; MSG="push a branch named tb/fifo_overflow_test"
  elif OG log --no-merges -p "origin/main..$T" | grep -q '^+.*DBG'; then ST=FAIL; MSG="a pushed commit contains the DBG print: see 'If you committed the debug print'"
  elif ! OG show "$T:tests/testlist" | grep -qx fifo_overflow || ! OG show "$T:tb/tb_fifo.sv" | grep -q '"fifo_overflow"'; then
    ST=FAIL; MSG="commit the fifo_overflow test in tb/tb_fifo.sv AND tests/testlist"
  elif run_at $T fifo_overflow; then ST=PASS; MSG=""
  else ST=FAIL; MSG="fifo_overflow fails on your pushed branch"; fi; }
c11() { local T=origin/tb/fifo_overflow_test RS
  RS=$(OG log --format=%H --fixed-strings --grep="tb: add fifo_reset test" origin/main | tail -n 1)
  if [ -z "$RS" ]; then ST=TODO; MSG="first run ../teammate.sh push-reset-test"
  elif ! has $T || ! contains "$RS" $T; then ST=TODO; MSG="git fetch, git merge origin/main on your branch, resolve, push"
  elif OG grep -q -E '^(<<<<<<<|=======|>>>>>>>)' "$T" -- . 2>/dev/null; then ST=FAIL; MSG="conflict markers were committed: remove them"
  elif ! { OG show "$T:tests/testlist" | grep -qx fifo_reset && OG show "$T:tests/testlist" | grep -qx fifo_overflow; }; then
    ST=FAIL; MSG="the testlist must keep BOTH fifo_overflow and fifo_reset"
  elif all_at $T; then ST=PASS; MSG=""
  else ST=FAIL; MSG="the full testlist does not pass on your pushed branch"; fi; }
c12() { local RL=origin/release/a0
  if ! OG log -1 --format=%B $RL | grep -q "cherry picked from commit"; then ST=TODO; MSG="cherry-pick the fix with -x onto release/a0 and push"
  elif OG show "$RL:tests/testlist" | grep -q -e fifo_overflow -e fifo_reset; then ST=FAIL; MSG="release/a0 got other changes too: only cherry-pick the one fix"
  elif ! run_at $RL fifo_full; then ST=FAIL; MSG="fifo_full still fails on release/a0"
  elif [ "$(OG cat-file -t a0_rc1 2>/dev/null)" != tag ]; then ST=TODO; MSG="now push an annotated tag a0_rc1 (git tag -a)"
  elif [ "$(OG rev-parse 'a0_rc1^{commit}')" != "$(OG rev-parse $RL)" ]; then ST=FAIL; MSG="a0_rc1 must point at the tip of release/a0"
  else ST=PASS; MSG=""; fi; }
c15() { if has origin/ci/smoke && OG show origin/ci/smoke:.gitlab-ci.yml 2>/dev/null | grep -q run_test.sh; then ST=PASS; MSG=""
  else ST=TODO; MSG="push .gitlab-ci.yml on a branch named ci/smoke"; fi; }

# ---------------------------------------------------------------- run one exercise
solved=0; failing=0; todo=0; written=0; STATUS_FILE="$tmp/status"
show() {  # num title status msg
  local c=$D
  case "$3" in PASS|DONE) c=$G ;; FAIL) c=$RD ;; SELF|BONUS) c=$Y ;; esac
  printf '%s  %-34s %s%-5s%s\n' "$1" "$2" "$c" "$3" "$N"
  [ -n "$4" ] && printf '      %s%s%s\n' "$D" "$4" "$N"
  echo "$1 $3" >> "$STATUS_FILE"
  return 0
}
todo_md() { [ ! -f "$1/commands.md" ] || grep -q "TODO: write the commands" "$1/commands.md"; }

check() {  # num title kind
  local num=$1 title=$2 kind=$3 dir ev ST=TODO MSG="" note=""
  dir=$(ls -d "$ROOT"/exercises/"$num"_*/ | head -n 1); dir=${dir%/}; ev="$dir/evidence"
  case $kind in
    config)
      if [ -f "$ev/config.txt" ]; then
        if grep -qx "rerere.enabled=true" "$ev/config.txt" && grep -q "^alias.lg=log" "$ev/config.txt"; then ST=PASS; else ST=FAIL; MSG="evidence/config.txt is not right"; fi
      elif [ $MODE = local ]; then
        if [ "$(git config --global rerere.enabled)" = true ] && [ -n "$(git config --global alias.lg)" ] && [ -n "$(git config --global user.name)" ]; then
          mkdir -p "$ev"
          { echo "rerere.enabled=$(git config --global rerere.enabled)"; echo "alias.lg=$(git config --global alias.lg)"; echo "pull.rebase=$(git config --global pull.rebase)"; } > "$ev/config.txt"
          ST=PASS; note="evidence saved"
        else MSG="need: user.name, rerere.enabled true, alias.lg"; fi
      fi ;;
    clone)
      if [ -f "$ev/clone.txt" ]; then
        if grep -q "origin: gitlab/fifo_dv.git" "$ev/clone.txt" && grep -q "nightly_fail_1017" "$ev/clone.txt"; then ST=PASS; else ST=FAIL; MSG="evidence/clone.txt is not right"; fi
      elif [ $MODE = local ]; then
        if [ -d "$R/.git" ] && git -C "$R" remote get-url origin 2>/dev/null | grep -q "gitlab/fifo_dv.git$"; then
          mkdir -p "$ev"
          { echo "origin: gitlab/fifo_dv.git"; git -C "$R" log --oneline --decorate -3 nightly_fail_1017; } > "$ev/clone.txt"
          ST=PASS; note="evidence saved"
        else MSG="cd work && git clone gitlab/fifo_dv.git"; fi
      fi ;;
    answer)
      local key=$4 a; a=$(ans "$key")
      if [ -z "$a" ]; then MSG="fill in $key in answers.txt"
      else case $key in
        e3_commit)    [ "$a" = nightly_fail_1017 ] && ST=PASS || { ST=FAIL; MSG="'$a' is not it: read the 'commit:' line of the log"; } ;;
        e4_suspects)  [ "$a" = 4 ] && ST=PASS || { ST=FAIL; MSG="count the commits in nightly_pass_1015..nightly_fail_1017"; } ;;
        e5_first_bad) a=$(echo "$a" | tr 'A-F' 'a-f')
                      if [ ${#a} -ge 7 ] && [ "${BAD#"$a"}" != "$BAD" ]; then ST=PASS; else ST=FAIL; MSG="not the first bad commit (use at least 7 characters)"; fi ;;
        e6_author)    a=$(echo "$a" | tr 'A-Z' 'a-z'); [[ "$a" == *priya* ]] && ST=PASS || { ST=FAIL; MSG="check: git blame -L 16,16 rtl/fifo.sv"; } ;;
      esac; fi ;;
    repo)
      local fn=$4 live_st="" live_msg=""
      if [ $MODE = local ]; then
        live_origin; $fn; live_st=$ST; live_msg=$MSG
        if [ "$live_st" = PASS ] && [ ! -f "$ev/gitlab.bundle" ]; then
          mkdir -p "$ev"; git -C "$ORIGIN" bundle create "$ev/gitlab.bundle" --all >/dev/null 2>&1; note="evidence saved"
        fi
      fi
      if [ -f "$ev/gitlab.bundle" ] && [ "$live_st" != PASS ]; then
        if bundle_origin "$ev/gitlab.bundle"; then $fn; else ST=FAIL; MSG="evidence/gitlab.bundle is damaged"; fi
        [ "$ST" = PASS ] && [ -n "$live_st" ] && MSG="solved earlier (evidence saved); your sandbox now: $live_st"
      fi ;;
    self)
      if todo_md "$dir"; then ST=SELF; MSG="practice only: write what you did in commands.md"; else ST=DONE; written=$((written + 1)); fi ;;
  esac
  if [ "$ST" = PASS ] && todo_md "$dir"; then MSG="${MSG:+$MSG; }now write your commands in commands.md"; fi
  [ -n "$note" ] && MSG="${note}${MSG:+; $MSG}"
  if [ "$num" != 15 ] && [ "$kind" != self ]; then
    case $ST in PASS) solved=$((solved + 1)) ;; FAIL) failing=$((failing + 1)) ;; *) todo=$((todo + 1)) ;; esac
  fi
  [ "$num" = 15 ] && [ "$ST" = TODO ] && ST=BONUS
  show "$num" "$title" "$ST" "$MSG"
}

printf '%s%-38s %s%s   %s(mode: %s)%s\n' "$B" "EXERCISE" "RESULT" "$N" "$D" "$MODE" "$N"
printf '%s\n' "----------------------------------------------"
check 01 "Set up Git once"                    config
check 02 "Clone and explore"                  clone
check 03 "Reproduce the failure"              answer e3_commit
check 04 "What changed between nightlies"     answer e4_suspects
check 05 "Find the bad commit (bisect)"       answer e5_first_bad
check 06 "Who changed the line (blame)"       answer e6_author
check 07 "Fix on a branch, push it"           repo c07
check 08 "Get the fix merged"                 repo c08
check 09 "Commit only what you mean (add -p)" repo c09
check 10 "Interrupted? stash"                 self
check 11 "Merge main, resolve the conflict"   repo c11
check 12 "Cherry-pick to release, tag it"     repo c12
check 13 "Reflog rescue"                      self
check 14 "Search with git grep"               self
check 15 "Bonus: CI pipeline file"            repo c15
printf '%s\n' "----------------------------------------------"
printf '%sSolved %d of 11%s' "$B" "$solved" "$N"
[ $failing -gt 0 ] && printf '  ·  %s%d failing%s' "$RD" "$failing" "$N"
printf '  ·  practice notes written: %d of 3\n' "$written"

if [ $MODE = local ] && [ -f README.md ]; then
  awk -v sf="$STATUS_FILE" -v solved="$solved" '
    BEGIN { while ((getline line < sf) > 0) { split(line, a, " "); st[a[1]] = a[2] } }
    /^[|] [0-9][0-9] [|]/ { n = substr($0, 3, 2)
      if (n in st) {
        s = st[n]
        icon = (s == "PASS") ? "✅ solved" : (s == "DONE") ? "✅ done" : (s == "FAIL") ? "❌ check failed" : (s == "SELF") ? "📝 practice" : "⬜ to do"
        sub(/[|] [^|]*[|]$/, "| " icon " |")
      } }
    /<!-- progress -->/ { sub(/<!-- progress -->.*<!-- \/progress -->/, "<!-- progress -->**Progress: " solved " / 11 solved**<!-- /progress -->") }
    { print }' README.md > "$tmp/readme" && cat "$tmp/readme" > README.md
fi

[ $MODE = ci ] && [ $failing -gt 0 ] && exit 1
exit 0
