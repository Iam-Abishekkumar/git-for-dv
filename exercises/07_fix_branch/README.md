# 07 · Fix it on a branch and push

**Guide section:** 8 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

1. `git switch -c fix/fifo_full_flag`
2. Undo the bad commit with `git revert`.
3. Run the whole testlist: `for t in $(cat tests/testlist); do scripts/run_test.sh "$t"; done`
4. Check what your Merge Request will contain: `git log --oneline main..HEAD`
5. `git push -u origin fix/fifo_full_flag`, and read GitLab's reply.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 07.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 07: fix it on a branch and push"`
