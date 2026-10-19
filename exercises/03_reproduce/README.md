# 03 · Reproduce the failure

**Guide section:** 5 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

1. `scripts/run_test.sh fifo_full`: it fails.
2. `head -n 3 sim/logs/fifo_full_1.log`
3. Open `../answers.txt` in Vim and set `e3_commit=` to the value on the `commit:` line.

Then try the `-dirty` experiment (add a comment to `tb/tb_fifo.sv`, rerun, `git restore tb/tb_fifo.sv`), and a worktree: `git worktree add ../fifo_good nightly_pass_1015`, run `fifo_full` there, then `git worktree remove ../fifo_good`.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 03.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 03: reproduce the failure"`
