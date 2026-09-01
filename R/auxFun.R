# function to check and change input to matrix #
checkM <- function(input){ # , inputname = NA
  if (!is.matrix(input)) {
    out <- as.matrix(input)
  } else{
    out <- input
  }
  colnames(out) <- NULL
  return(out)
}
# end check matrix fun #

# Convert arbitrary one-column panel identifiers to consecutive integer codes.
# Character and factor labels are accepted.  The codes are used only in
# internal numeric work matrices; fitted objects retain the original labels.
.panel_id_code <- function(idvar){
  id_matrix <- if (is.matrix(idvar)) idvar else as.matrix(idvar)
  if (ncol(id_matrix) != 1L) {
    stop("idvar must contain exactly one column")
  }

  ids <- as.vector(id_matrix)
  if (length(ids) == 0L) {
    stop("idvar must contain at least one observation")
  }
  if (any(is.na(ids))) {
    stop("idvar must not contain missing values")
  }

  out <- matrix(match(ids, unique(ids)), ncol = 1L)
  rownames(out) <- rownames(id_matrix)
  out
}

# Apply either an ordinary logical row selection or a block-bootstrap index.
.prepare_panel_resample <- function(ind, data){
  if (is.logical(ind)) {
    if (length(ind) == 1L) {
      ind <- rep(ind, nrow(data))
    }
    if (length(ind) != nrow(data) || any(is.na(ind))) {
      stop("logical ind must have length one or one value per data row")
    }
    rows <- which(ind)
    newid <- data[rows, "idvar", drop = FALSE]
  } else {
    rows <- as.integer(ind)
    if (length(rows) == 0L || any(is.na(rows)) ||
        any(rows < 1L | rows > nrow(data))) {
      stop("ind contains invalid row indices")
    }
    bootstrap_ids <- rownames(ind)
    if (is.null(bootstrap_ids) || length(bootstrap_ids) != length(rows)) {
      stop("bootstrap indices must carry resampled panel IDs as row names")
    }
    newid <- matrix(as.numeric(bootstrap_ids), ncol = 1L)
    if (any(is.na(newid))) {
      stop("bootstrap panel IDs must be numeric")
    }
  }

  list(data = data[rows, , drop = FALSE], idvar = newid)
}

# function to check and change input - dummy variables - to matrix #
checkMD <- function(input){ # , inputname = NA
  if (!is.matrix(input)) {
    out <- as.matrix(input)
  } else{
    out <- input
  }
  colnames(out) <- NULL
  if (any( (out != 0) & (out != 1) ) ){ # if exit is not binary, stop the routine
    nm <-deparse(substitute(input))
    stop(paste(nm, "is not binary"))
  }
  return(out)
}
# end check matrix fun #

# function to lag variables within a panel #
lagPanel <- function(idvar, timevar, value){
  idvar <- as.vector(idvar)
  timevar <- as.vector(timevar)

  if (length(idvar) != length(timevar)) {
    stop("idvar and timevar must have the same length")
  }
  if (!is.numeric(timevar)) {
    stop("timevar must be numeric")
  }

  vector_input <- is.null(dim(value))
  value_matrix <- if (vector_input) matrix(value, ncol = 1L) else as.matrix(value)

  if (nrow(value_matrix) != length(idvar)) {
    stop("value must have one row for each idvar/timevar observation")
  }

  valid <- !is.na(idvar) & !is.na(timevar)
  source_key <- rep(NA_character_, length(idvar))
  source_key[valid] <- paste(idvar[valid], timevar[valid], sep = "\r")

  if (anyDuplicated(source_key[valid])) {
    stop("idvar and timevar must uniquely identify observations")
  }

  target_key <- rep(NA_character_, length(idvar))
  target_key[valid] <- paste(idvar[valid], timevar[valid] - 1, sep = "\r")
  source_row <- match(target_key, source_key)

  out <- value_matrix[source_row, , drop = FALSE]
  out[!valid, ] <- NA

  if (vector_input) {
    out <- as.vector(out[, 1L])
    names(out) <- names(value)
    return(out)
  }

  input_names <- colnames(value_matrix)
  if (is.null(input_names)) {
    input_names <- paste0("V", seq_len(ncol(value_matrix)))
  }
  colnames(out) <- paste0("l", input_names)
  rownames(out) <- rownames(value_matrix)
  out
}
# end of lag panel #

# function to demean a vector and take the variance #
withinvar <- function(inmat){
  devmat = inmat - mean(inmat) # demean the vector
  return(var(c(devmat)))
}
# end of within variance function #

# boot resampling on IDs: bootstrapping on individuals #
block.boot.resample <- function(idvar, R){
  id_matrix <- if (is.matrix(idvar)) idvar else as.matrix(idvar)
  if (ncol(id_matrix) != 1L) {
    stop("idvar must contain exactly one column")
  }

  ids <- as.vector(id_matrix)
  if (length(ids) == 0L) {
    stop("idvar must contain at least one observation")
  }
  if (any(is.na(ids))) {
    stop("idvar must not contain missing values")
  }
  if (length(R) != 1L || is.na(R) || !is.finite(R) ||
      R < 1L || R != as.integer(R)) {
    stop("R must be a positive integer")
  }
  R <- as.integer(R)

  unique_ids <- unique(ids)
  panel_indices <- lapply(unique_ids, function(x) which(ids == x))
  n_panels <- length(panel_indices)

  lapply(seq_len(R), function(r) {
    sampled_panels <- sample.int(n_panels, size = n_panels, replace = TRUE)
    sampled_indices <- unlist(panel_indices[sampled_panels], use.names = FALSE)
    bootstrap_ids <- unlist(
      Map(function(new_id, sampled_panel) {
        rep.int(new_id, length(panel_indices[[sampled_panel]]))
      }, seq_along(sampled_panels), sampled_panels),
      use.names = FALSE
    )

    matrix(
      sampled_indices,
      ncol = 1L,
      dimnames = list(as.character(bootstrap_ids), NULL)
    )
  })
}
# end of block bootstrap function #

# function to compute the weighting matrix #
weightM <- function(Y, X1, X2, Z1, Z2, betas, numR, SE = FALSE){
  k1 <- ncol(X1)
  N <- nrow(X1)
  R1t <- Y - X1 %*% betas[1 : k1, drop = FALSE]
  R2t <- Y - X2 %*% c(betas[1 : numR], betas[(k1 + 1) : length(betas), drop = FALSE]) # (fnum + snum + cnum + 1)
  u <- c(R1t, R2t) # alternative, still working
  Z <- as.matrix( bdiag(Z1, Z2)) # drop the collinear constant
  sigma.rs <- (t(u) %*% u)
  S <- sigma.rs[1] * ( ( t(Z) %*% Z) ) # /N
  if (SE == TRUE){
    dX <- rbind( cbind( X1, matrix(0, N, (ncol(X2) - numR) ) ),
                 cbind( X2[, 1 : numR], matrix(0 , N, (ncol(X1) - numR) ), X2[,(numR + 1) : ncol(X2)]) ) # generate a "quasi-block" matrix with common columns NON-BLOCK
    var.beta <- (1/N) * solve( ( t(dX) %*% Z ) %*% solve(S) %*% (t(Z) %*% dX) ) # compute varCovar matrix
    st.errors <- sqrt(diag(var.beta))
    return(st.errors)
  } else {
    W = solve(S)
    return(W)
  }
}
# end of weighting matrix function #

# function to print lateX table of results #
printProd <- function(mods, modnames = NULL, parnames = NULL, outfile = NULL, ptime = FALSE, nboot = FALSE, screen = FALSE){
  if (!is.null(outfile)) (sink(outfile)) # write on a text file
  numMods <- length(mods)
  numPars <- length(mods[[1]]@Estimates$pars)
  if (screen == FALSE){
    cat(paste('\\begin{tabular}{', paste(rep('c',(numMods*2+1)), collapse = ''),'}',
              '\\hline\\hline', sep = '')) # print tabular header
    nm <- '\n'
    obs <- '\nN'
    time <- '\nTime'
    boot <- '\nBootRep'
    for (m in 1:numMods){ # generate first and last row: names (methods or user-supplied) and observations
      if (is.null(modnames)){
        nm <- paste(nm, mods[[m]]@Model$method, sep = ' & & ')
      }else{
        nm <- paste(nm, modnames[m], sep = ' & & ')
      }
      obs <- paste(obs, length(mods[[m]]@Data$Y), sep = ' & & ')
      time <- paste(time, round(mods[[m]]@Model$elapsed.time[[1]], digits = 2), sep = ' & & ')
      boot <- paste(boot, mods[[m]]@Model$boot.repetitions, sep = ' & & ')
    }
    nm <- paste(nm, '\\\\\\hline')
    obs <- paste(obs, '\\\\\\hline\\hline')
    cat(nm)
    for (p in 1:numPars){ # generate the table body row by row: names (vars or user-supplied),
      if (is.null(parnames)){
        betas <- paste('\n', names(mods[[1]]@Estimates$pars)[p])
      }
      else{
        betas <- paste('\n', parnames[p])
      }
      sigmas <- '\n'
      blank <- '\n'
      for (m in 1:numMods){
        betas <- paste(betas, round(mods[[m]]@Estimates$pars[p],digits = 3), sep = ' & & ')
        sigma <- paste('(', round(mods[[m]]@Estimates$std.errors[p],digits = 3), ')', sep = '')
        sigmas <- paste(sigmas, sigma , sep = ' & & ')
        blank <- paste(blank, ' & ',  sep = '')
      }
      betas <- paste(betas, '\\\\')
      sigmas <- paste(sigmas, '\\\\')
      blank <- paste(blank, '\\\\')
      cat(betas)
      cat(sigmas)
      cat(blank)
    }
    cat(blank)
    if (ptime == TRUE) (cat(paste(time, '\\\\', sep = '')))
    if (nboot == TRUE) (cat(paste(boot, '\\\\', sep = '')))
    cat(obs)
    cat('\n\\end{tabular}')
    if (!is.null(outfile)) (sink())
  } else{
    cat(paste(rep('--', (numMods*3+1), sep = ''))) # print
    nm <- '\n'
    obs <- '\nN'
    time <- '\nTime'
    boot <- '\nBootRep'
    for (m in 1:numMods){ # generate first and last row: names (methods or user-supplied) and observations
      if (is.null(modnames)){
        nm <- paste(nm, mods[[m]]@Model$method, sep = '       ')
      }else{
        nm <- paste(nm, modnames[m], sep = '  ')
      }
      obs <- paste(obs, length(mods[[m]]@Data$Y), sep = '    ')
      time <- paste(time, round(mods[[m]]@Model$elapsed.time[[1]], digits = 2), sep = '  ')
      boot <- paste(boot, mods[[m]]@Model$boot.repetitions, sep = '  ')
    }
    cat(nm)
    cat('\n')
    cat(paste(rep('--',(numMods*3+1), sep = ''))) # print
    for (p in 1:numPars){ # generate the table body row by row: names (vars or user-supplied),
      if (is.null(parnames)){
        betas <- paste('\n', names(mods[[1]]@Estimates$pars)[p])
      }
      else{
        betas <- paste('\n', parnames[p])
      }
      sigmas <- '\n   '
      blank <- ''
      for (m in 1:numMods){
        betas <- paste(betas, round(mods[[m]]@Estimates$pars[p],digits = 3), sep = '   ')
        sigma <- paste('(', round(mods[[m]]@Estimates$std.errors[p],digits = 3), ')', sep = '')
        sigmas <- paste(sigmas, sigma , sep = ' ')
        blank <- paste(blank, rep('--',(numMods*2+1)),  sep = '')
      }
      cat(betas)
      cat(sigmas)
      cat('\n')
      cat(blank)
    }
    if (ptime == TRUE) (cat(paste(time, '', sep = '')))
    if (nboot == TRUE) (cat(paste(boot, '', sep = '')))
    cat(obs)
    cat('\n')
    cat(blank)
  }
}
# end of latex print table #

