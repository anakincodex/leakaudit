test_that("identical hashes land in the same group", {
  hashes <- data.frame(
    path = c("a.jpg", "b.jpg", "c.jpg"),
    hash = c("0000000000000000", "0000000000000000", "ffffffffffffffff"),
    stringsAsFactors = FALSE
  )
  out <- find_duplicate_groups(hashes, threshold = 5)
  expect_equal(out$group_id[1], out$group_id[2])
  expect_false(out$group_id[1] == out$group_id[3])
})

test_that("transitive grouping: A~B~C all merge even if A and C are far apart", {
  # A and B close, B and C close, A and C NOT close -> should still be one group
  hashes <- data.frame(
    path = c("a", "b", "c"),
    hash = c(
      "0000000000000000",  # A
      "0000000000000003",  # B: 2 bits from A
      "0000000000000300"   # C: 2 bits from B, but 4 bits from A
    ),
    stringsAsFactors = FALSE
  )
  out <- find_duplicate_groups(hashes, threshold = 3)
  expect_equal(length(unique(out$group_id)), 1)
})

test_that("images with no near-duplicates get singleton groups", {
  hashes <- data.frame(
    path = c("a", "b", "c", "d"),
    hash = c("0000000000000000", "1111111111111111",
             "2222222222222222", "3333333333333333"),
    stringsAsFactors = FALSE
  )
  out <- find_duplicate_groups(hashes, threshold = 2)
  expect_equal(length(unique(out$group_id)), 4)
})

test_that("NA hashes are treated as singletons, not errors", {
  hashes <- data.frame(
    path = c("a", "b"),
    hash = c(NA_character_, "0000000000000000"),
    stringsAsFactors = FALSE
  )
  out <- find_duplicate_groups(hashes, threshold = 5)
  expect_equal(nrow(out), 2)
  expect_false(out$group_id[1] == out$group_id[2])
})

test_that("row order is preserved", {
  hashes <- data.frame(
    path = c("z", "a", "m"),
    hash = c("ffffffffffffffff", "0000000000000000", "1111111111111111"),
    stringsAsFactors = FALSE
  )
  out <- find_duplicate_groups(hashes, threshold = 1)
  expect_equal(out$path, c("z", "a", "m"))
})
