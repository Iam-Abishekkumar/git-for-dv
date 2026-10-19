# 14 · Search with git grep

**Guide section:** 14 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Practice only: counts as done when you fill in `commands.md`.**

## Do it

Compare `grep -rn "fifo_overflow" --exclude-dir=.git .` with `git grep -n "fifo_overflow"`, then search old code with `git grep -n "DEPTH" nightly_pass_1015 -- rtl/`.

Practice only: it counts as done when you write `commands.md`.

## Done?

1. Write the commands you used in [commands.md](commands.md).
2. `../check.sh` (from `work/fifo_dv`) now shows **DONE** for 14.
3. Save to GitHub: `../save.sh "Solve 14: search with git grep"`
