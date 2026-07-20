#' Audit train/val/test leakage from duplicate groups
#'
#' Given duplicate groups (from [find_duplicate_groups()]) and each
#' image's split assignment, reports how many groups span more than one
#' split -- i.e. how many near-duplicate images "leak" across the
#' train/validation/test boundary -- and what fraction of each split is
#' affected.
#'
#' @param grouped_df A data frame with columns `path`, `group_id`, and
#'   `split`, as produced by [find_duplicate_groups()] (with `split`
#'   supplied to [compute_hashes()]).
#'
#' @return An object of class `leakage_report` (a list) with:
#'   \describe{
#'     \item{leaked_groups}{data frame of group_ids that span >1 split,
#'       with the splits involved and member count}
#'     \item{n_leaked_images}{total images sitting in a leaked group}
#'     \item{pct_leaked_by_split}{named numeric vector, % of each split's
#'       images that belong to a leaked group}
#'     \item{total_images}{total images audited}
#'   }
#'
#' @examples
#' groups <- data.frame(
#'   path = c("a.jpg", "b.jpg", "c.jpg", "d.jpg"),
#'   split = c("train", "test", "train", "val"),
#'   group_id = c(1, 1, 2, 3)
#' )
#' dhash_audit(groups)
#'
#' @export
dhash_audit <- function(grouped_df) {
  stopifnot(
    is.data.frame(grouped_df),
    all(c("path", "group_id", "split") %in% names(grouped_df))
  )

  by_group <- split(grouped_df, grouped_df$group_id)

  leak_rows <- lapply(names(by_group), function(gid) {
    g <- by_group[[gid]]
    splits_here <- unique(g$split[!is.na(g$split)])
    if (length(splits_here) > 1) {
      data.frame(
        group_id = as.integer(gid),
        n_members = nrow(g),
        splits_involved = paste(sort(splits_here), collapse = ", "),
        stringsAsFactors = FALSE
      )
    } else {
      NULL
    }
  })
  leaked_groups <- do.call(rbind, leak_rows)
  if (is.null(leaked_groups)) {
    leaked_groups <- data.frame(
      group_id = integer(0), n_members = integer(0),
      splits_involved = character(0), stringsAsFactors = FALSE
    )
  }

  leaked_ids <- leaked_groups$group_id
  is_leaked <- grouped_df$group_id %in% leaked_ids

  pct_by_split <- tapply(is_leaked, grouped_df$split, function(x) {
    round(100 * mean(x), 2)
  })

  structure(
    list(
      leaked_groups = leaked_groups,
      n_leaked_images = sum(is_leaked),
      pct_leaked_by_split = pct_by_split,
      total_images = nrow(grouped_df)
    ),
    class = "leakage_report"
  )
}

#' @export
print.leakage_report <- function(x, ...) {
  cat("<leakage_report>\n")
  cat(sprintf(
    "  %d / %d images (%.2f%%) sit in a duplicate group that spans more than one split\n",
    x$n_leaked_images, x$total_images,
    100 * x$n_leaked_images / max(x$total_images, 1)
  ))
  cat(sprintf("  %d duplicate groups leak across splits\n", nrow(x$leaked_groups)))
  if (length(x$pct_leaked_by_split) > 0) {
    cat("  leakage by split:\n")
    for (nm in names(x$pct_leaked_by_split)) {
      cat(sprintf("    %s: %.2f%%\n", nm, x$pct_leaked_by_split[[nm]]))
    }
  }
  invisible(x)
}
