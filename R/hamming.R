#' Hamming distance between two hex-encoded perceptual hashes
#'
#' Computes the number of differing bits between two perceptual hashes
#' encoded as hexadecimal strings (as produced by [compute_hashes()]).
#'
#' @param hash1 A character scalar or vector of hex-encoded hashes.
#' @param hash2 A character scalar or vector of hex-encoded hashes, the
#'   same length as `hash1` (or length 1, recycled).
#'
#' @return An integer vector of Hamming distances (number of differing bits).
#'
#' @examples
#' hamming_distance("ff00", "ff01")
#' hamming_distance(c("ffff", "0000"), "0000")
#'
#' @export
hamming_distance <- function(hash1, hash2) {
  if (length(hash1) == 0 || length(hash2) == 0) {
    return(integer(0))
  }

  n <- max(length(hash1), length(hash2))
  hash1 <- rep_len(hash1, n)
  hash2 <- rep_len(hash2, n)

  vapply(seq_len(n), function(i) {
    .hex_hamming_pair(hash1[i], hash2[i])
  }, integer(1))
}

# Internal: Hamming distance between a single pair of hex strings.
.hex_hamming_pair <- function(h1, h2) {
  if (is.na(h1) || is.na(h2)) {
    return(NA_integer_)
  }
  if (nchar(h1) != nchar(h2)) {
    stop("Hashes must be the same length to compare (got ",
         nchar(h1), " and ", nchar(h2), " hex characters).", call. = FALSE)
  }

  b1 <- .hex_to_bits(h1)
  b2 <- .hex_to_bits(h2)
  sum(b1 != b2)
}

# Internal: hex string -> logical bit vector
.hex_to_bits <- function(hex_string) {
  nibbles <- strsplit(tolower(hex_string), "")[[1]]
  bits <- unlist(lapply(nibbles, function(ch) {
    val <- strtoi(ch, base = 16L)
    as.logical(intToBits(val)[1:4])
  }))
  bits
}
