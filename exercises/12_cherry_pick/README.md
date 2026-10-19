# 12 · Cherry-pick to the release branch and tag it

**Guide section:** 12 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

1. `git switch release/a0`, then run `fifo_full`. It fails: the release still has the bug.
2. Find the fix's ID on main: `git log --oneline main`
3. `git cherry-pick -x <id>`, then rerun `fifo_full`.
4. Before pushing, `git log --oneline origin/release/a0..HEAD` must show **exactly one** commit.
5. `git push`
6. `git tag -a a0_rc1 -m "A0 release candidate 1: regression clean"`, then `git push origin a0_rc1`, then `git describe`

If step 4 shows more than one commit (you merged instead of cherry-picking), undo with `git reset --hard origin/release/a0` and try again.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 12.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 12: cherry-pick to the release branch and tag it"`
