############ ACKERBERG-CAVES-FRAZER ###############

# Prepare the numeric matrices used by the ACF estimator.  Keeping this step
# separate makes the dimensions of control-variable models directly testable.
.prepare_acf_data <- function(Y, fX, sX, pX, idvar, timevar, cX = NULL){
  snum <- ncol(sX)
  fnum <- ncol(fX)
  cnum <- if (is.null(cX)) 0L else ncol(cX)

  polyframe <- data.frame(fX, sX, pX)
  mod <- model.matrix(~ .^2 - 1, data = polyframe)
  mod <- mod[match(rownames(polyframe), rownames(mod)), , drop = FALSE]

  # Put first-degree production inputs first.  This gives finalACF() stable
  # starting-value positions; lm() drops later duplicate first-degree columns.
  if (is.null(cX)) {
    regvars <- cbind(fX, sX, pX, mod, fX^2, sX^2, pX^2)
  } else {
    regvars <- cbind(fX, sX, cX, pX, mod, fX^2, sX^2, pX^2)
  }

  lag.sX <- sX
  for (i in seq_len(snum)) {
    lag.sX[, i] <- lagPanel(sX[, i], idvar = idvar, timevar = timevar)
  }

  lag.fX <- fX
  for (i in seq_len(fnum)) {
    lag.fX[, i] <- lagPanel(fX[, i], idvar = idvar, timevar = timevar)
  }

  idvar.internal <- .panel_id_code(idvar)
  if (is.null(cX)) {
    data <- as.matrix(data.frame(
      Y = Y,
      idvar = idvar.internal,
      timevar = timevar,
      Z = data.frame(lag.fX, sX),
      Xt = data.frame(fX, sX),
      lX = data.frame(lag.fX, lag.sX),
      regvars = regvars
    ))
  } else {
    lag.cX <- cX
    for (i in seq_len(cnum)) {
      lag.cX[, i] <- lagPanel(cX[, i], idvar = idvar, timevar = timevar)
    }

    # Controls are estimated production-function regressors.  Their current
    # and lagged values must therefore enter the second-stage matrices, while
    # their lags also enter the instrument matrix.
    data <- as.matrix(data.frame(
      Y = Y,
      idvar = idvar.internal,
      timevar = timevar,
      Z = data.frame(lag.fX, sX, lag.cX),
      Xt = data.frame(fX, sX, cX),
      lX = data.frame(lag.fX, lag.sX, lag.cX),
      regvars = regvars
    ))
  }

  storage.mode(data) <- "double"
  data
}

# function to estimate ACF model #
prodestACF <- function(Y, fX, sX, pX, idvar, timevar, R = 20, cX = NULL,
                       opt = 'optim', theta0 = NULL, cluster = NULL){
  Start <- Sys.time()
  Y <- checkM(Y)
  fX <- checkM(fX)
  sX <- checkM(sX)
  pX <- checkM(pX)
  idvar <- checkM(idvar)
  idvar.original <- idvar
  timevar <- checkM(timevar)
  snum <- ncol(sX)
  fnum <- ncol(fX)
  if (!is.null(cX)) {
    cX <- checkM(cX)
    cnum <- ncol(cX)
  } else {
    cnum <- 0L
  }
  n.parameters <- cnum + fnum + snum
  if (!is.null(theta0) && length(theta0) != n.parameters) {
    stop(paste0('theta0 length (', length(theta0),
                ') is inconsistent with the number of parameters (',
                n.parameters, ')'))
  }

  data <- .prepare_acf_data(
    Y = Y, fX = fX, sX = sX, pX = pX, idvar = idvar,
    timevar = timevar, cX = cX
  )

  betas <- finalACF(
    ind = TRUE, data = data, fnum = fnum, snum = snum, cnum = cnum,
    opt = opt, theta0 = theta0
  )
  boot.indices <- block.boot.resample(idvar, R)
  if (is.null(cluster)) {
    nCores <- NULL
    boot.betas <- matrix(
      unlist(lapply(
        boot.indices, finalACF, data = data, fnum = fnum, snum = snum,
        cnum = cnum, opt = opt, theta0 = theta0, boot = TRUE
      )),
      ncol = n.parameters, byrow = TRUE
    )
  } else {
    nCores <- length(cluster)
    clusterEvalQ(cl = cluster, library(prodest))
    boot.betas <- matrix(
      unlist(parLapply(
        cl = cluster, boot.indices, finalACF, data = data, fnum = fnum,
        snum = snum, cnum = cnum, opt = opt, theta0 = theta0,
        boot = TRUE
      )),
      ncol = n.parameters, byrow = TRUE
    )
  }
  boot.errors <- apply(boot.betas, 2, sd, na.rm = TRUE)
  res.names <- c(
    colnames(fX, do.NULL = FALSE, prefix = 'fX'),
    colnames(sX, do.NULL = FALSE, prefix = 'sX')
  )
  if (!is.null(cX)) {
    res.names <- c(res.names, colnames(cX, do.NULL = FALSE, prefix = 'cX'))
  }
  names(betas$betas) <- res.names
  names(boot.errors) <- res.names
  elapsedTime <- Sys.time() - Start
  out <- new(
    "prod",
    Model = list(
      method = 'ACF', FSbetas = NA, boot.repetitions = R,
      elapsed.time = elapsedTime, theta0 = theta0, opt = opt,
      opt.outcome = betas$opt.outcome, nCores = nCores
    ),
    Data = list(
      Y = Y, free = fX, state = sX, proxy = pX, control = cX,
      idvar = idvar.original, timevar = timevar,
      FSresiduals = betas$FSresiduals
    ),
    Estimates = list(pars = betas$betas, std.errors = boot.errors)
  )
  return(out)
}
# end of prodestACF #

# function to estimate and bootstrap ACF #
finalACF <- function(ind, data, fnum, snum, cnum, opt, theta0,
                     boot = FALSE){
  sampled <- .prepare_panel_resample(ind, data)
  data <- sampled$data
  newid <- sampled$idvar
  n.parameters <- fnum + snum + cnum

  first.stage <- lm(
    data[, 'Y', drop = FALSE] ~
      data[, grepl('regvars', colnames(data)), drop = FALSE],
    na.action = na.exclude
  )
  phi <- fitted(first.stage)
  if (is.null(theta0)) {
    theta0 <- as.numeric(coef(first.stage)[2:(1 + n.parameters)]) +
      rnorm(n.parameters, 0, 0.01)
  }
  newtime <- data[, 'timevar', drop = FALSE]
  rownames(phi) <- NULL
  rownames(newtime) <- NULL
  lag.phi <- lagPanel(idvar = newid, timevar = newtime, value = phi)
  Z <- data[, grepl('Z', colnames(data)), drop = FALSE]
  X <- data[, grepl('Xt', colnames(data)), drop = FALSE]
  lX <- data[, grepl('lX', colnames(data)), drop = FALSE]
  tmp.data <- model.frame(Z ~ X + lX + phi + lag.phi)
  W <- solve(crossprod(tmp.data$Z)) / nrow(tmp.data$Z)

  if (opt == 'optim') {
    try.out <- try(
      optim(
        theta0, gACF, method = "BFGS", mZ = tmp.data$Z, mW = W,
        mX = tmp.data$X, mlX = tmp.data$lX, vphi = tmp.data$phi,
        vlag.phi = tmp.data$lag.phi
      ),
      silent = TRUE
    )
    if (!inherits(try.out, "try-error")) {
      betas <- try.out$par
      opt.outcome <- try.out
    } else {
      betas <- rep(NA_real_, n.parameters)
      opt.outcome <- list(convergence = 999)
    }
  } else if (opt == 'DEoptim') {
    try.out <- try(
      DEoptim(
        gACF, lower = theta0, upper = rep.int(1, length(theta0)),
        mZ = tmp.data$Z, mW = W, mX = tmp.data$X, mlX = tmp.data$lX,
        vphi = tmp.data$phi, vlag.phi = tmp.data$lag.phi,
        control = DEoptim.control(trace = FALSE)
      ),
      silent = TRUE
    )
    if (!inherits(try.out, "try-error")) {
      betas <- try.out$optim$bestmem
      opt.outcome <- try.out
    } else {
      betas <- rep(NA_real_, n.parameters)
      opt.outcome <- list(convergence = 99)
    }
  } else if (opt == 'solnp') {
    try.out <- try(
      suppressWarnings(solnp(
        theta0, gACF, mZ = tmp.data$Z, mW = W, mX = tmp.data$X,
        mlX = tmp.data$lX, vphi = tmp.data$phi,
        vlag.phi = tmp.data$lag.phi, control = list(trace = FALSE)
      )),
      silent = TRUE
    )
    if (!inherits(try.out, "try-error")) {
      betas <- try.out$pars
      opt.outcome <- try.out
    } else {
      betas <- rep(NA_real_, n.parameters)
      opt.outcome <- list(convergence = 999)
    }
  } else {
    stop("opt must be one of 'optim', 'DEoptim' or 'solnp'")
  }

  if (!boot) {
    return(list(
      betas = betas, opt.outcome = opt.outcome,
      FSresiduals = resid(first.stage)
    ))
  }
  betas
}
# end of ACF final function #

# function to run the GMM estimation for ACF #
gACF <- function(theta, mZ, mW, mX, mlX, vphi, vlag.phi){
  theta <- as.numeric(theta)
  if (ncol(mX) != length(theta) || ncol(mlX) != length(theta)) {
    stop("theta must contain one value for each column of mX and mlX")
  }
  Omega <- vphi - mX %*% theta
  Omega_lag <- vlag.phi - mlX %*% theta
  Omega_lag_pol <- cbind(1, Omega_lag, Omega_lag^2, Omega_lag^3)
  g_b <- solve(crossprod(Omega_lag_pol)) %*%
    t(Omega_lag_pol) %*% Omega
  XI <- Omega - Omega_lag_pol %*% g_b
  crit <- t(crossprod(mZ, XI)) %*% mW %*% crossprod(mZ, XI)
  return(crit)
}
# end of GMM ACF #
