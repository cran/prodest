library(prodest)

## Regression test for vector and matrix inputs to lagPanel().
id <- c(1, 1, 2, 2)
time <- c(1, 2, 1, 2)
x <- c(10, 20, 30, 40)
expected <- c(NA_real_, 10, NA_real_, 30)

stopifnot(isTRUE(all.equal(
  lagPanel(id, time, x),
  expected,
  check.attributes = FALSE
)))

stopifnot(isTRUE(all.equal(
  lagPanel(x, idvar = id, timevar = time),
  expected,
  check.attributes = FALSE
)))

x_matrix <- cbind(a = x, b = x + 100)
lagged_matrix <- lagPanel(id, time, x_matrix)
stopifnot(
  is.matrix(lagged_matrix),
  identical(dim(lagged_matrix), c(4L, 2L)),
  identical(colnames(lagged_matrix), c("la", "lb")),
  isTRUE(all.equal(lagged_matrix[, 1], expected, check.attributes = FALSE)),
  isTRUE(all.equal(lagged_matrix[, 2], expected + 100, check.attributes = FALSE))
)

## Regression test for the panelSim() vector-recycling warning.
set.seed(123)
warnings_seen <- character()
simulated <- withCallingHandlers(
  panelSim(N = 5, T = 20),
  warning = function(w) {
    warnings_seen <<- c(warnings_seen, conditionMessage(w))
    invokeRestart("muffleWarning")
  }
)
stopifnot(
  length(warnings_seen) == 0L,
  nrow(simulated) == 10L,
  ncol(simulated) == 9L,
  identical(
    names(simulated),
    c("idvar", "timevar", "Y", "sX", "fX", "pX1", "pX2", "pX3", "pX4")
  )
)

## Regression tests for character panel identifiers (GitHub issue #20).
character_id <- c("firm-a", "firm-a", "firm-b", "firm-b", "firm-b", "firm-c")
character_time <- c(1, 2, 1, 2, 3, 1)
character_value <- seq_along(character_id)
expected_character_lag <- c(NA_real_, 1, NA_real_, 3, 4, NA_real_)
stopifnot(isTRUE(all.equal(
  lagPanel(character_id, character_time, character_value),
  expected_character_lag,
  check.attributes = FALSE
)))

panel_id_code <- getFromNamespace(".panel_id_code", "prodest")
encoded_id <- panel_id_code(character_id)
stopifnot(
  is.matrix(encoded_id),
  identical(dim(encoded_id), c(6L, 1L)),
  identical(as.integer(encoded_id), c(1L, 1L, 2L, 2L, 2L, 3L))
)

set.seed(321)
bootstrap_indices <- block.boot.resample(character_id, R = 4)
stopifnot(length(bootstrap_indices) == 4L)
for (indices in bootstrap_indices) {
  stopifnot(
    is.matrix(indices),
    ncol(indices) == 1L,
    all(indices[, 1] %in% seq_along(character_id)),
    !is.null(rownames(indices))
  )
  sampled_panels <- split(as.integer(indices[, 1]), rownames(indices))
  stopifnot(length(sampled_panels) == length(unique(character_id)))
  for (rows in sampled_panels) {
    source_id <- character_id[rows[1]]
    stopifnot(
      length(unique(character_id[rows])) == 1L,
      identical(unname(rows), which(character_id == source_id))
    )
  }
}

## Regression test for ACF controls (GitHub issue #11).
prepare_acf_data <- getFromNamespace(".prepare_acf_data", "prodest")
acf_id <- rep(c("a", "b", "c"), each = 5)
acf_time <- rep(seq_len(5), 3)
acf_n <- length(acf_id)
acf_fX <- matrix(seq(0.2, 1.6, length.out = acf_n), ncol = 1,
                 dimnames = list(NULL, "labour"))
acf_sX <- matrix(seq(1.1, 2.5, length.out = acf_n), ncol = 1,
                 dimnames = list(NULL, "capital"))
acf_pX <- matrix(seq(0.7, 1.4, length.out = acf_n), ncol = 1,
                 dimnames = list(NULL, "materials"))
acf_cX <- matrix(seq(-0.3, 0.4, length.out = acf_n), ncol = 1,
                 dimnames = list(NULL, "control"))
acf_Y <- matrix(1 + 0.4 * acf_fX + 0.3 * acf_sX + 0.2 * acf_cX,
                ncol = 1)
acf_data <- prepare_acf_data(
  Y = acf_Y, fX = acf_fX, sX = acf_sX, pX = acf_pX,
  idvar = acf_id, timevar = acf_time, cX = acf_cX
)
stopifnot(
  is.matrix(acf_data),
  storage.mode(acf_data) == "double",
  sum(grepl("^Z", colnames(acf_data))) == 3L,
  sum(grepl("^Xt", colnames(acf_data))) == 3L,
  sum(grepl("^lX", colnames(acf_data))) == 3L,
  identical(
    as.integer(acf_data[, "idvar"]),
    rep(1:3, each = 5)
  )
)
acf_regvars <- acf_data[, grepl("^regvars", colnames(acf_data)), drop = FALSE]
stopifnot(
  isTRUE(all.equal(acf_regvars[, 1], acf_fX[, 1], check.attributes = FALSE)),
  isTRUE(all.equal(acf_regvars[, 2], acf_sX[, 1], check.attributes = FALSE)),
  isTRUE(all.equal(acf_regvars[, 3], acf_cX[, 1], check.attributes = FALSE))
)

## The GMM criterion must accept one coefficient per free, state and control
## regressor without a non-conformable-matrix error.
criterion_n <- 30L
criterion_index <- seq_len(criterion_n)
criterion_theta <- c(0.2, 0.3, 0.1)
criterion_X <- cbind(
  criterion_index / criterion_n,
  sin(criterion_index / 3),
  cos(criterion_index / 5)
)
criterion_lX <- cbind(
  (criterion_index - 1) / criterion_n,
  sin((criterion_index - 1) / 3),
  cos((criterion_index - 1) / 5)
)
criterion_omega_lag <- seq(-1, 1, length.out = criterion_n)
criterion_lag_phi <- criterion_lX %*% criterion_theta + criterion_omega_lag
criterion_omega <- 0.4 + 0.7 * criterion_omega_lag +
  0.2 * criterion_omega_lag^2 + 0.05 * criterion_index / criterion_n
criterion_phi <- criterion_X %*% criterion_theta + criterion_omega
criterion_Z <- cbind(
  criterion_index / criterion_n,
  sin(criterion_index / 4),
  cos(criterion_index / 6)
)
criterion_W <- solve(crossprod(criterion_Z)) / criterion_n
criterion_value <- gACF(
  criterion_theta, mZ = criterion_Z, mW = criterion_W,
  mX = criterion_X, mlX = criterion_lX,
  vphi = criterion_phi, vlag.phi = criterion_lag_phi
)
stopifnot(
  is.matrix(criterion_value),
  identical(dim(criterion_value), c(1L, 1L)),
  is.finite(criterion_value[1, 1])
)

## Regression test for the corrected packaged Chilean data (GitHub issue #22).
data("chilean", package = "prodest")
stopifnot(
  nrow(chilean) == 2544L,
  identical(
    names(chilean),
    c("Y", "sX", "fX1", "fX2", "pX", "inv", "idvar", "timevar")
  ),
  !"cX" %in% names(chilean),
  identical(range(chilean$timevar), c(1996, 2006)),
  !isTRUE(all.equal(chilean$pX, chilean$inv, check.attributes = FALSE))
)
