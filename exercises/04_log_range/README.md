# 04 · What changed between the nightlies

**Guide section:** 6 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

```bash
git log --oneline nightly_pass_1015..nightly_fail_1017
git diff --stat nightly_pass_1015 nightly_fail_1017
```

Set `e4_suspects=` in `../answers.txt` to the number of commits between the two tags.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 04.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 04: what changed between the nightlies"`
