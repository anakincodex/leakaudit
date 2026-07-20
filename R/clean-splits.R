#' Produce a leak-free split assignment
#'
#' Resolves duplicate groups that span multiple splits by assigning every
#' member of a leaked group to a single split, chosen by `priority`. This
#' mirrors the common convention of keeping duplicates in `train` (so no
#' information is discarded, only potential evaluation leakage) but any
#' priority order can be supplied.
#'
#' @param grouped_df A data frame with columns `path`, `group_id`, and
#'   `split`, as produced by [find_duplicate_groups()].
#' @param priority Character vector giving split precedence, highest
#'   priority first. Defaults to `c("train", "val", "test")`: a leaked
#'   group touching train and test is fully reassigned to train.
#'
#' @return `grouped_df` with `split` replaced by the corrected,
#'   leak-free assignment, plus a logical column `reassigned` flagging
#'   which rows were changed.
#'
#' @examples
#' groups <- data.frame(
#'   path = c("a.jpg", "b.jpg", "c.jpg"),
#'   split = c("train", "test", "val"),
#'   group_id = c(1, 1, 2)
#' )
#' clean_splits(groups)
#'
#' @export
clean_splits <- function(grouped_df, priority = c("train", "val", "test")) {
  stopifnot(
    is.data.frame(grouped_df),
    all(c("path", "group_id", "split") %in% names(grouped_df))
  )

  original_split <- grouped_df$split
  by_group <- split(seq_len(nrow(grouped_df)), grouped_df$group_id)

  for (rows in by_group) {
    splits_here <- unique(grouped_df$split[rows])
    splits_here <- splits_here[!is.na(splits_here)]
    if (length(splits_here) > 1) {
      ranked <- priority[priority %in% splits_here]
      winner <- if (length(ranked) > 0) ranked[1] else splits_here[1]
      grouped_df$split[rows] <- winner
    }
  }

  grouped_df$reassigned <- !identical(original_split, grouped_df$split) &
    (original_split != grouped_df$split)
  grouped_df$reassigned[is.na(grouped_df$reassigned)] <- FALSE
  grouped_df
}
