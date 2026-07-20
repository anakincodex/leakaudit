#' Compute perceptual hashes for a set of images
#'
#' Computes a 64-bit difference hash (dHash) for each image path. dHash is
#' robust to resizing, mild compression, and small crops, which makes it
#' well suited to catching near-duplicate images that differ only in
#' resolution, format, or minor edits -- the kind of duplication that
#' commonly leaks across train/validation/test splits.
#'
#' @param paths Character vector of file paths to image files. Any format
#'   readable by [magick::image_read()] is supported (jpg, png, tif, ...).
#' @param split A character vector the same length as `paths` giving the
#'   split each image currently belongs to (e.g. `"train"`, `"val"`,
#'   `"test"`). Optional; if omitted, all images are treated as unsplit.
#'
#' @return A data frame with columns `path`, `split`, and `hash` (a 16
#'   character hex string encoding the 64-bit dHash). Any path that fails
#'   to load produces `NA` in `hash` with a warning, rather than stopping
#'   the whole run.
#'
#' @examples
#' \dontrun{
#' hashes <- compute_hashes(
#'   paths = list.files("images/", full.names = TRUE),
#'   split = rep(c("train", "test"), length.out = 10)
#' )
#' }
#'
#' @export
compute_hashes <- function(paths, split = NULL) {
  if (!requireNamespace("magick", quietly = TRUE)) {
    stop("Package 'magick' is required to compute hashes from image files.",
         call. = FALSE)
  }

  if (is.null(split)) {
    split <- rep(NA_character_, length(paths))
  } else if (length(split) != length(paths)) {
    stop("`split` must be the same length as `paths`.", call. = FALSE)
  }

  hashes <- vapply(paths, .dhash_one, character(1))

  data.frame(
    path = paths,
    split = split,
    hash = unname(hashes),
    stringsAsFactors = FALSE
  )
}

# Internal: compute a single 64-bit dHash as a 16-char hex string.
# Algorithm: grayscale -> resize to 9x8 -> compare each pixel to its
# right-hand neighbour -> 8*8 = 64 bits -> pack into hex.
.dhash_one <- function(path) {
  img <- tryCatch(
    magick::image_read(path),
    error = function(e) NULL
  )
  if (is.null(img)) {
    warning("Could not read image, skipping: ", path, call. = FALSE)
    return(NA_character_)
  }

  small <- magick::image_resize(img, "9x8!")
  small <- magick::image_convert(small, colorspace = "gray")
  raster <- magick::image_data(small, channels = "gray")

  # raster is a raw array [channel, x, y]; drop to numeric matrix [x, y]
  mat <- matrix(as.integer(raster[1, , ]), nrow = 9, ncol = 8)

  bits <- logical(64)
  k <- 1
  for (y in seq_len(8)) {
    for (x in seq_len(8)) {
      bits[k] <- mat[x, y] > mat[x + 1, y]
      k <- k + 1
    }
  }

  .bits_to_hex(bits)
}

# Internal: logical vector of length 64 -> 16 char hex string
.bits_to_hex <- function(bits) {
  nibble_vals <- vapply(seq(1, 64, by = 4), function(i) {
    chunk <- bits[i:(i + 3)]
    sum(chunk * c(1L, 2L, 4L, 8L))
  }, integer(1))
  paste(sprintf("%x", nibble_vals), collapse = "")
}
