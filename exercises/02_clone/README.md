# 02 · Clone and explore

**Guide section:** 4 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

From the top folder:

```bash
cd work
git clone gitlab/fifo_dv.git
cd fifo_dv
git lg
git ls-files
scripts/run_test.sh fifo_basic
git status --short --ignored
../check.sh
```

From now on you practise inside `work/fifo_dv`. Think: the simulation created `sim/`, so why does plain `git status` say nothing?

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 02.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 02: clone and explore"`
