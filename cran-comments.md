## Test environments

* local: Ubuntu 24.04, R 4.3.3
* (add win-builder / R-hub / GitHub Actions results here before submitting)

## R CMD check results

0 errors | 0 warnings | 0 notes (on local Ubuntu run; re-check on
win-builder and R-hub before submission, since CRAN's own build
environments may surface platform-specific notes not visible locally).

## Comments

This is the first submission of leakaudit to CRAN.

The package detects near-duplicate images across train/validation/test
splits using perceptual hashing (dHash), reports resulting leakage, and
produces a corrected split assignment. It is distinct in scope from other
CRAN packages with superficially similar names (e.g. leakr, bioLeak), which
address leakage in tabular/biomedical ML workflows rather than image
datasets; see the README for details.
