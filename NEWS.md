# leakaudit 0.1.0

Initial CRAN release.

* `compute_hashes()`: compute 64-bit dHash perceptual hashes for a set of
  image files.
* `find_duplicate_groups()`: cluster images into near-duplicate groups by
  Hamming distance.
* `dhash_audit()`: report how many duplicate groups, and what percentage of
  each split, are contaminated across train/validation/test boundaries.
* `clean_splits()`: produce a corrected, leak-free split assignment by
  reassigning leaked groups according to a priority order.
* `hamming_distance()`: exported helper for comparing hex-encoded hashes.
