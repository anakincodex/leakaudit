# leakaudit

Detects near-duplicate images across train/validation/test splits using
perceptual hashing (dHash), reports the resulting leakage, and produces a
corrected, leak-free split assignment.

## Why

When building an image classification dataset, near-duplicate images
(same photo re-saved, resized, lightly cropped, or recompressed) commonly
end up split across train and test. This silently inflates test-set
performance, since the model has effectively already seen a
near-identical copy of the "unseen" example.

## Install

```r
# development version
remotes::install_github("anakincodex/leakaudit")

# from CRAN, once published
install.packages("leakaudit")
```

## Usage

```r
library(leakaudit)

hashes  <- compute_hashes(image_paths, split = split_labels)
grouped <- find_duplicate_groups(hashes, threshold = 5)
report  <- dhash_audit(grouped)
print(report)

clean <- clean_splits(grouped, priority = c("train", "val", "test"))
```

## How this differs from other leakage packages

A few CRAN packages deal with "leakage" in machine learning workflows, but
none of them work at the image level:

- **leakr** and **bioLeak** detect leakage in tabular/biomedical data
  (row overlap, target leakage, batch confounding). They operate on
  data frames of features and outcomes, not image files.
- **OpenImageR** provides general-purpose perceptual hashing
  (`dhash()`, `phash()`) but has no concept of dataset splits or leakage
  reporting.

leakaudit is specifically about auditing and fixing near-duplicate
contamination across image dataset splits, and its `dhash_audit()` function
is unrelated to `bioLeak::audit_leakage()`, which audits fitted models on
tabular data via permutation testing.
