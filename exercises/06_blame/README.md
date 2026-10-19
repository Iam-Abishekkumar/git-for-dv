# 06 · Who changed the line

**Guide section:** 7 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

Use `git show <id>`, `git blame -L 16,16 rtl/fifo.sv` and `git log -S "DEPTH-1" --oneline`.

Set `e6_author=` in `../answers.txt` to the person who wrote the bad line.

## Done?

1. `../check.sh` (from `work/fifo_dv`) shows **PASS** for 06.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `../save.sh "Solve 06: who changed the line"`
