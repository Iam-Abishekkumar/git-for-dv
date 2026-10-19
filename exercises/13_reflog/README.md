# 13 · Reflog rescue

**Guide section:** 13 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Practice only: counts as done when you fill in `commands.md`.**

## Do it

On `tb/fifo_overflow_test`:

```bash
git log --oneline -3
git reset --hard HEAD~2        # the "mistake"
git log --oneline -3           # two commits gone?
git reflog -5
git reset --hard HEAD@{1}      # pick the line from before the reset
git status -sb                 # should match origin again
```

Practice only: it counts as done when you write `commands.md`.

## Done?

1. Write the commands you used in [commands.md](commands.md).
2. `../check.sh` (from `work/fifo_dv`) now shows **DONE** for 13.
3. Save to GitHub: `../save.sh "Solve 13: reflog rescue"`
