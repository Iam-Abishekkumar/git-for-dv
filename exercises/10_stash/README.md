# 10 · Interrupted? git stash

**Guide section:** 10 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Practice only: counts as done when you fill in `commands.md`.**

## Do it

```bash
../make_edits.sh wip                      # a half-finished edit
git stash push -m "wip: overflow coverage counter"
git switch main
scripts/run_test.sh fifo_full
git switch -
git stash list
git stash pop
git restore tb/tb_fifo.sv                 # drop the WIP so exercise 11 starts clean
```

Practice only: there is no automatic check. It counts as done when you write `commands.md`.

## Done?

1. Write the commands you used in [commands.md](commands.md).
2. `../check.sh` (from `work/fifo_dv`) now shows **DONE** for 10.
3. Save to GitHub: `../save.sh "Solve 10: interrupted? git stash"`
