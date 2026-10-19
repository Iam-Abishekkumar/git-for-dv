# 08 · Get it merged

**Guide section:** 8 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

```bash
../teammate.sh merge fix/fifo_full_flag
git switch main
git pull
```

Karthik runs the full regression on the merged result and merges only if everything passes, like a real CI gate.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 08.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 08: get it merged"`
