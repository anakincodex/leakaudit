#' Group near-duplicate images by hash distance
#'
#' Given a table of image hashes (as produced by [compute_hashes()]),
#' clusters images into duplicate groups: any two images within
#' `threshold` Hamming distance of each other are placed in the same
#' group, and group membership propagates transitively (A~B~C all end
#' up in one group even if A and C aren't directly close).
#'
#' @param hash_df A data frame with at least columns `path` and `hash`,
#'   as returned by [compute_hashes()].
#' @param threshold Maximum Hamming distance (in bits, out of 64) for two
#'   images to be considered near-duplicates. Defaults to `5`, a
#'   reasonably conservative value for dHash; lower it for stricter
#'   (exact-duplicate-only) matching, raise it to catch more aggressive
#'   near-duplicates at the cost of more false positives.
#'
#' @return `hash_df` with an added integer column `group_id`. Images with
#'   no near-duplicates get their own unique `group_id`. Row order is
#'   preserved.
#'
#' @examples
#' hashes <- data.frame(
#'   path = c("a.jpg", "b.jpg", "c.jpg", "d.jpg"),
#'   hash = c("0000000000000000", "0000000000000001",
#'            "ffffffffffffffff", "1234567890abcdef")
#' )
#' find_duplicate_groups(hashes, threshold = 5)
#'
#' @export
find_duplicate_groups <- function(hash_df, threshold = 5) {
  stopifnot(
    is.data.frame(hash_df),
    all(c("path", "hash") %in% names(hash_df))
  )

  n <- nrow(hash_df)
  parent <- seq_len(n)

  find_root <- function(x) {
    while (parent[x] != x) {
      parent[x] <<- parent[parent[x]]
      x <- parent[x]
    }
    x
  }
  union_ids <- function(a, b) {
    ra <- find_root(a)
    rb <- find_root(b)
    if (ra != rb) parent[ra] <<- rb
  }

  valid <- which(!is.na(hash_df$hash))
  if (length(valid) >= 2) {
    for (i in seq_along(valid)[-length(valid)]) {
      idx_i <- valid[i]
      remaining <- valid[(i + 1):length(valid)]
      dists <- hamming_distance(hash_df$hash[idx_i], hash_df$hash[remaining])
      close <- remaining[dists <= threshold]
      for (j in close) union_ids(idx_i, j)
    }
  }

  roots <- vapply(seq_len(n), find_root, integer(1))
  # renumber roots to compact, stable 1..k group ids in order of appearance
  group_id <- match(roots, unique(roots))

  hash_df$group_id <- group_id
  hash_df
}
