# 01 · Set up Git once

**Guide section:** 3 of *Git for DV Engineers* (`docs/Git_for_DV_Engineers.pdf`)
**Checked automatically: when it passes, `check.sh` saves proof in `evidence/`.**

## Do it

These settings save time every day. If your name and email are already set (`git config --global user.name`), keep them.

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global pull.rebase false
git config --global rerere.enabled true
git config --global alias.lg "log --oneline --graph --decorate --all"
git config --global alias.st "status -sb"
./check.sh
```

Run this one from the top folder (`git-for-dv`).

## Done?

1. `./check.sh` (from the top folder `git-for-dv`) shows **PASS** for 01.
2. Write the commands you used in [commands.md](commands.md).
3. Save to GitHub: `./save.sh "Solve 01: set up git once"`
