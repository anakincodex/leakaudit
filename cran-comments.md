## Test environments

* local: Windows 11, R-devel, Rtools45
* win-builder: R-devel (2026-07-19 r90279 ucrt), Windows Server 2022 x64
* R-hub v2 (via GitHub Actions): linux, windows, macos, macos-arm64, m1-san,
  and 28 additional compiler/sanitizer/config variants (gcc13-16, clang16-22,
  atlas, valgrind, lto, mkl, nold, noremap, donttest, c23, ubuntu-clang,
  ubuntu-gcc12, ubuntu-next, ubuntu-release, intel)

## R CMD check results

0 errors | 0 warnings | 0 notes locally and on R-hub.

win-builder returned 1 NOTE, which is the standard "New submission" note
expected for a first-time CRAN submission:

  Maintainer: 'Kartik Patel <kartikpatel.id@gmail.com>'
  New submission

Two R-hub platforms reported failures unrelated to the package:

* `nosuggests`: fails to rebuild the vignette because this configuration
  deliberately omits all Suggests packages, including rmarkdown (the
  vignette engine declared via VignetteBuilder: knitr). rmarkdown is
  correctly listed under Suggests and is only required at vignette-build
  time, not for the package's exported functionality.
* `rchk`: this platform statically analyzes compiled C/C++/Fortran code
  for memory-protection issues. leakaudit is pure R with no compiled
  code (no src/ directory), so there is nothing for rchk to analyze; the
  failure originates in the platform's own tooling, not the package.

## Comments

This is the first submission of leakaudit to CRAN.

The package detects near-duplicate images across train/validation/test
splits using perceptual hashing (dHash), reports resulting leakage, and
produces a corrected split assignment. It is distinct in scope from other
CRAN packages with superficially similar names (e.g. leakr, bioLeak), which
address leakage in tabular/biomedical ML workflows rather than image
datasets; see the README for details.