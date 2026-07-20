test_that("identical hashes have distance 0", {
  expect_equal(hamming_distance("ffff", "ffff"), 0L)
  expect_equal(hamming_distance("0000000000000000", "0000000000000000"), 0L)
})

test_that("known bit differences are counted correctly", {
  # 0x0 = 0000, 0x1 = 0001 -> differ in 1 bit
  expect_equal(hamming_distance("0", "1"), 1L)
  # 0x0 vs 0xf -> differ in all 4 bits
  expect_equal(hamming_distance("0", "f"), 4L)
  # ff00 vs ff01 -> only last nibble differs by 1 bit
  expect_equal(hamming_distance("ff00", "ff01"), 1L)
})

test_that("vectorised over both arguments with recycling", {
  result <- hamming_distance(c("ffff", "0000"), "0000")
  expect_equal(result, c(16L, 0L))
})

test_that("mismatched hash lengths error clearly", {
  expect_error(hamming_distance("ff", "ffff"), "same length")
})

test_that("NA hashes propagate as NA, not error", {
  expect_equal(hamming_distance(NA_character_, "ffff"), NA_integer_)
})
