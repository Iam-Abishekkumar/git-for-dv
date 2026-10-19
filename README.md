# Git for Design Verification

[![check](https://github.com/Iam-Abishekkumar/git-for-dv/actions/workflows/check.yml/badge.svg)](https://github.com/Iam-Abishekkumar/git-for-dv/actions/workflows/check.yml)

15 hands-on exercises on the Git workflows a verification team uses every day: finding the commit that broke a
regression with `git bisect`, fixing it on a branch, committing only what you mean with `git add -p`, resolving
testlist conflicts, cherry-picking a fix to a release branch, and recovering lost work with `git reflog`.
Every exercise runs real simulations (a FIFO with a self-checking SystemVerilog testbench, Icarus Verilog).

## How it works

```text
 git-for-dv  (this repo, on GitHub)            work/  (sandbox, never committed)
 ├── exercises/NN/README.md    the task   ──►  gitlab/fifo_dv.git   pretend GitLab with the team's history
 ├── exercises/NN/commands.md  my commands     fifo_dv/              my clone: I practise here
 └── exercises/NN/evidence/    proof      ◄──  check.sh saves it the first time an exercise passes
            │
            └──►  GitHub Actions unpacks the evidence and re-runs every check and simulation (badge above)
```

> **About the history inside the sandbox:** the commits by "Priya Raman" and "Karthik S" are simulated teammates
> created by `start.sh`, so the exercises have a realistic team history to work with. My own work is what I did in
> each exercise: the commits in the evidence bundles made after that history, my answers and my `commands.md` notes.

## Quick start

```bash
sudo apt install git iverilog vim
git clone https://github.com/Iam-Abishekkumar/git-for-dv.git
cd git-for-dv
./start.sh                              # build the sandbox in work/ (once)
cat exercises/01_setup/README.md
```

## Daily loop

1. Read the exercise: `exercises/NN_*/README.md`, plus the matching section of the guide in `docs/`.
2. Practise in `work/fifo_dv` and run `../check.sh` until it shows **PASS**.
3. Write your commands in `exercises/NN_*/commands.md`.
4. Save to GitHub: `../save.sh "Solve NN: ..."` (it commits the **git-for-dv** repo, never the sandbox).

## Exercises

<!-- progress -->**Progress: 1 / 11 solved**<!-- /progress -->

| # | Exercise | Guide section | Status |
|---|---|---|---|
| 01 | [Set up Git once](exercises/01_setup/) | 3 | ✅ solved |
| 02 | [Clone and explore](exercises/02_clone/) | 4 | ⬜ to do |
| 03 | [Reproduce the failure](exercises/03_reproduce/) | 5 | ⬜ to do |
| 04 | [What changed between the nightlies](exercises/04_log_range/) | 6 | ⬜ to do |
| 05 | [Find the bad commit with bisect](exercises/05_bisect/) | 6 | ⬜ to do |
| 06 | [Who changed the line](exercises/06_blame/) | 7 | ⬜ to do |
| 07 | [Fix it on a branch and push](exercises/07_fix_branch/) | 8 | ⬜ to do |
| 08 | [Get it merged](exercises/08_merge_request/) | 8 | ⬜ to do |
| 09 | [Commit only what you mean (git add -p)](exercises/09_add_patch/) | 9 | ⬜ to do |
| 10 | [Interrupted? git stash](exercises/10_stash/) | 10 | 📝 practice |
| 11 | [Merge main and resolve the conflict](exercises/11_conflict/) | 11 | ⬜ to do |
| 12 | [Cherry-pick to the release branch and tag it](exercises/12_cherry_pick/) | 12 | ⬜ to do |
| 13 | [Reflog rescue](exercises/13_reflog/) | 13 | 📝 practice |
| 14 | [Search with git grep](exercises/14_git_grep/) | 14 | 📝 practice |
| 15 | [Bonus: a CI pipeline file](exercises/15_bonus_ci/) | 15 | ⬜ to do |

Exercises 10, 13 and 14 are practice only (no automatic check). 15 is a bonus.

## Start again

`./start.sh --reset` rebuilds the sandbox from scratch. Your saved evidence, answers and notes stay, so you can
redo every exercise faster, without the guide.

## Files

| Path | What it is |
|---|---|
| `start.sh` | Builds the sandbox in `work/` |
| `check.sh` | Scoreboard. `--ci` re-verifies the saved evidence only (used by GitHub Actions) |
| `save.sh` | Commit and push your progress in this repo |
| `teammate.sh`, `make_edits.sh` | A teammate who reviews and merges; code edits typed for you |
| `answers.txt` | Answers for exercises 03 to 06 |
| `lab/` | The files used to build the sandbox history |
| `docs/` | *Git for DV Engineers* guide (PDF) |

## Requirements

Linux or WSL with `git`, `iverilog` and `vim`.
