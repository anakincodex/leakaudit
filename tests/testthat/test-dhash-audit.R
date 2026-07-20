test_that("group spanning two splits is flagged as leaked", {
  groups <- data.frame(
    path = c("a", "b", "c", "d"),
    split = c("train", "test", "train", "val"),
    group_id = c(1, 1, 2, 3),
    stringsAsFactors = FALSE
  )
  report <- dhash_audit(groups)
  expect_s3_class(report, "leakage_report")
  expect_equal(nrow(report$leaked_groups), 1)
  expect_equal(report$leaked_groups$group_id, 1)
  expect_equal(report$n_leaked_images, 2)
  expect_equal(report$total_images, 4)
})

test_that("no leakage when every group stays within one split", {
  groups <- data.frame(
    path = c("a", "b", "c"),
    split = c("train", "train", "test"),
    group_id = c(1, 1, 2),
    stringsAsFactors = FALSE
  )
  report <- dhash_audit(groups)
  expect_equal(nrow(report$leaked_groups), 0)
  expect_equal(report$n_leaked_images, 0)
})

test_that("pct_leaked_by_split is computed per split", {
  groups <- data.frame(
    path = c("a", "b", "c", "d"),
    split = c("train", "test", "train", "train"),
    group_id = c(1, 1, 2, 2),
    stringsAsFactors = FALSE
  )
  report <- dhash_audit(groups)
  # group 1 (train+test) leaks; group 2 (train-only) doesn't
  expect_equal(unname(report$pct_leaked_by_split["test"]), 100)
  expect_equal(round(unname(report$pct_leaked_by_split["train"]), 2), 33.33)
})

test_that("print method runs without error", {
  groups <- data.frame(
    path = c("a", "b"), split = c("train", "test"),
    group_id = c(1, 1), stringsAsFactors = FALSE
  )
  report <- dhash_audit(groups)
  expect_output(print(report), "leakage_report")
})
