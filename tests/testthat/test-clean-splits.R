test_that("leaked group is fully reassigned to the highest-priority split", {
  groups <- data.frame(
    path = c("a", "b", "c"),
    split = c("train", "test", "val"),
    group_id = c(1, 1, 1),
    stringsAsFactors = FALSE
  )
  out <- clean_splits(groups, priority = c("train", "val", "test"))
  expect_true(all(out$split == "train"))
})

test_that("custom priority order is respected", {
  groups <- data.frame(
    path = c("a", "b"),
    split = c("train", "test"),
    group_id = c(1, 1),
    stringsAsFactors = FALSE
  )
  out <- clean_splits(groups, priority = c("test", "train"))
  expect_true(all(out$split == "test"))
})

test_that("non-leaked groups are left untouched", {
  groups <- data.frame(
    path = c("a", "b", "c"),
    split = c("train", "train", "test"),
    group_id = c(1, 1, 2),
    stringsAsFactors = FALSE
  )
  out <- clean_splits(groups)
  expect_equal(out$split, c("train", "train", "test"))
  expect_false(any(out$reassigned))
})

test_that("reassigned flag correctly marks changed rows only", {
  groups <- data.frame(
    path = c("a", "b", "c"),
    split = c("train", "test", "val"),
    group_id = c(1, 1, 2),
    stringsAsFactors = FALSE
  )
  out <- clean_splits(groups, priority = c("train", "val", "test"))
  expect_equal(out$reassigned, c(FALSE, TRUE, FALSE))
})
