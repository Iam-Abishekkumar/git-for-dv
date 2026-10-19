# 11 · Merge main and resolve the conflict

**Guide section:** 11 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

1. `../teammate.sh push-reset-test`: Karthik adds `fifo_reset` to `main`.
2. `git fetch origin`, then `git log --oneline HEAD..origin/main`
3. `git merge origin/main`: the testlist conflicts.
4. Open `tests/testlist` in Vim. Keep **both** new tests and delete the three marker lines.
5. `git add tests/testlist`, then `git commit -m "Merge origin/main into tb/fifo_overflow_test"`. Look for `Recorded resolution`.
6. Run the whole testlist (5 tests), then `git push`.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 11.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 11: merge main and resolve the conflict"`
