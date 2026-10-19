# 05 · Find the bad commit with bisect

**Guide section:** 6 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

```bash
git bisect start nightly_fail_1017 nightly_pass_1015
git bisect run scripts/run_test.sh fifo_full
git bisect reset
```

Set `e5_first_bad=` in `../answers.txt` to the first bad commit's ID (7 characters or more). Then do it again **by hand**: after each step run the test yourself and type `git bisect good` or `git bisect bad`.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 05.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 05: find the bad commit with bisect"`
