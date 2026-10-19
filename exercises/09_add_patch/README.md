# 09 · Commit only what you mean (git add -p)

**Guide section:** 9 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

1. From the updated `main`: `git switch -c tb/fifo_overflow_test`
2. `../make_edits.sh overflow` adds the new test **and** a debug `$display` you must not commit.
3. `git diff`, then `git add -p tb/tb_fifo.sv`: `n` for the `DBG` hunk, `y` for the test.
4. `git add tests/testlist`, `git status --short` (expect `MM`), then commit.
5. `git restore tb/tb_fifo.sv` drops the debug print. Run `scripts/run_test.sh fifo_overflow`.
6. `git push -u origin tb/fifo_overflow_test`

**If you committed the debug print** (`check.sh` says so):

```bash
git reset --soft HEAD~1             # undo the commit, keep the changes
git restore --staged tb/tb_fifo.sv  # unstage the testbench
git add -p tb/tb_fifo.sv            # this time: n for DBG, y for the test
git commit -m "tb: add fifo_overflow test"
git restore tb/tb_fifo.sv
git push --force-with-lease         # only ever on your OWN branch
```

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 09.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 09: commit only what you mean"`
