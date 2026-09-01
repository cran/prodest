\name{prodestOP}
\alias{prodestOP}
\title{
	Estimate productivity - Olley-Pakes method
}
\description{
The \code{prodestOP()} function accepts at least 6 objects (id, time, output, free, state and proxy variables), and returns a \code{prod} object of class \code{S4} with three elements: (i) a list of model-related objects, (ii) a list with the data used in the estimation and estimated vectors of first-stage residuals, and (iii) a list with the estimated parameters and their bootstrapped standard errors .
}
\usage{
  prodestOP(Y, fX, sX, pX, idvar, timevar, R = 20, cX = NULL,
            opt = 'optim', theta0 = NULL, cluster = NULL, tol = 1e-100, exit = FALSE)
}
\arguments{
  \item{Y      }{
  the vector of value added log output.}
  %
  \item{fX     }{
  the vector/matrix/dataframe of log free variables.}
  %
  \item{sX     }{
  the vector/matrix/dataframe of log state variables.}
  %
  \item{pX    }{
  the vector/matrix/dataframe of log proxy variables.}
  %
  \item{cX     }{
  the vector/matrix/dataframe of control variables. By default \code{cX= NULL}.}
  %
  \item{idvar  }{
  a one-column vector/matrix/dataframe identifying individual panels; numeric, character and factor labels are accepted.}
  %
  \item{timevar}{
  the vector/matrix/dataframe identifying time.}
  %
  \item{R      }{
  the number of block bootstrap repetitions to be performed in the standard error estimation. By default \code{R = 20}.}
  %
  \item{opt    }{
  a string with the optimization algorithm to be used during the estimation. By default \code{opt = 'optim'}.}
  %
  \item{theta0 }{
  a vector with the second stage optimization starting points. By default \code{theta0 = NULL} and the optimization is run starting from the first stage estimated parameters + \eqn{N(\mu=0,\sigma=0.01)} noise.}
  %
  \item{cluster}{
    an object of class \code{"SOCKcluster"} or \code{"cluster"}. By default \code{cluster = NULL}.}
  %
  \item{tol}{
    optimizer tolerance. By default \code{tol = 1e-100}.}
  %
  \item{exit}{
    Indicator for attrition in the data - i.e., if firms exit the market. By default \code{exit = FALSE}; if \code{exit = TRUE}, an indicator function for firms whose last appearance is before the last observation's date is generated and used in the second stage. The user can even specify an indicator variable/matrix/dataframe with the exit years.}
  %
}
%%%%%%%%% DETAILS %%%%%%%%%%%
\details{
  Consider a Cobb-Douglas production technology for firm \eqn{i} at time \eqn{t}
  \itemize{
    \item \eqn{y_{it} = \alpha + w_{it}\beta + k_{it}\gamma + \omega_{it} + \epsilon_{it}}
  }
  where \eqn{y_{it}} is the (log) output, \eqn{w_{it}} is a \eqn{1 \times J}{1 x J} vector of (log) free variables, \eqn{k_{it}} is a \eqn{1 \times K}{1 x K} vector of state variables, and \eqn{\epsilon_{it}} is a normally distributed idiosyncratic error term.
  The unobserved technical efficiency parameter \eqn{\omega_{it}} evolves according to a first-order Markov process:
  \itemize{
    \item \eqn{\omega_{it} = E(\omega_{it} | \omega_{it-1}) + u_{it} = g(\omega_{it-1}) + u_{it}}
  }
  and \eqn{u_{it}} is a random shock component assumed to be uncorrelated with the technical efficiency, the state variables in \eqn{k_{it}} and the lagged free variables \eqn{w_{it-1}}.
  The OP method relies on the following set of assumptions:
  \itemize{
    \item a) \eqn{i_{it} = i(k_{it},\omega_{it})} - investments are a function of both the state variable and the technical efficiency parameter;
    \item b) \eqn{i_{it}} is strictly monotone in \eqn{\omega_{it}};
    \item c) \eqn{\omega_{it}} is scalar unobservable in \eqn{i_{it} = i(.)} ;
    \item d) the levels of \eqn{i_{it}} and \eqn{k_{it}} are decided at time \eqn{t-1}; the level of the free variable, \eqn{w_{it}}, is decided after the shock \eqn{u_{it}} realizes.
  }
  Assumptions a)-d) ensure the invertibility of \eqn{i_{it}} in \eqn{\omega_{it}} and lead to the partially identified model:
  \itemize{
    \item \eqn{y_{it} = \alpha + w_{it}\beta + k_{it}\gamma + h(i_{it}, k_{it}) + \epsilon_{it} = \alpha + w_{it}\beta  + \phi(i_{it}, k_{it}) + \epsilon_{it} }
  }
  which is estimated by a non-parametric approach - First Stage.
  Exploiting the Markovian nature of the productivity process one can use assumption d) in order to set up the relevant moment conditions and estimate the production function parameters - Second stage.
  Exploiting the residual \eqn{e_{it}} of:
  \itemize{
    \item \eqn{y_{it} - w_{it}\hat{\beta} = \alpha + k_{it}\gamma + g(\omega_{it-1}, \chi_{it}) + \epsilon_{it} }
  }
  and \eqn{g(.)} is typically left unspecified and approximated by a \eqn{n^{th}} order polynomial and \eqn{\chi_{it}} is an indicator function for the attrition in the market.
}
%%%%%%%%% VALUE %%%%%%%%%%%
\value{
    The output of the function \code{prodestOP} is a member of the \code{S3} class \pkg{prod}. More precisely, is a list (of length 3) containing the following elements:

    \code{Model}, a list containing:
    \itemize{
      \item \code{method:} a string describing the method ('OP').
      \item \code{boot.repetitions:} the number of bootstrap repetitions used for standard errors' computation.
      \item \code{elapsed.time:} time elapsed during the estimation.
      \item \code{theta0:} numeric object with the optimization starting points - second stage.
      \item \code{opt:} string with the optimization routine used - 'optim', 'solnp' or 'DEoptim'.
      \item \code{opt.outcome:} optimization outcome.
      \item \code{FSbetas:} first stage estimated parameters.
    }

    \code{Data}, a list containing:
    \itemize{
      \item \code{Y:} the vector of value added log output.
      \item \code{free:} the vector/matrix/dataframe of log free variables.
      \item \code{state:} the vector/matrix/dataframe of log state variables.
      \item \code{proxy:} the vector/matrix/dataframe of log proxy variables.
      \item \code{control:} the vector/matrix/dataframe of log control variables.
      \item \code{idvar:} the vector/matrix/dataframe identifying individual panels.
      \item \code{timevar:} the vector/matrix/dataframe identifying time.
      \item \code{FSresiduals:} numeric object with the residuals of the first stage.
    }

    \code{Estimates}, a list containing:
    \itemize{
      \item \code{pars:} the vector of estimated coefficients.
      \item \code{std.errors:} the vector of bootstrapped standard errors.
    }

    Members of class \code{prod} have an \code{omega} method returning a numeric object with the estimated productivity - that is: \eqn{\omega_{it} = y_{it} - (\alpha + w_{it}\beta + k_{it}\gamma)}.
    \code{FSres} method returns a numeric object with the residuals of the first stage regression, while \code{summary}, \code{show} and \code{coef} methods are implemented and work as usual.
}
%%%%%%%%% AUTHOR %%%%%%%%%%%
\author{Gabriele Rovigatti}
%%%%%%%%% REFERENCES %%%%%%%%%%%
\references{
  Olley, S G and Pakes, A (1996).
  "The dynamics of productivity in the telecommunications equipment industry."
  Econometrica, 64(6), 1263-1297.
}
%%%%%%%%% EXAMPLES %%%%%%%%%%%
\examples{
    require(prodest)

    ## Source: Instituto Nacional de Estadisticas de Chile (ENIA).

    data(chilean)

    # we fit a model with two free (skilled and unskilled), one state (capital)
    # and one proxy variable (investment)

    OP.fit <- prodestOP(chilean$Y, fX = cbind(chilean$fX1, chilean$fX2), chilean$sX,
                        chilean$inv, chilean$idvar, chilean$timevar)
    OP.fit.solnp <- prodestOP(chilean$Y, fX = cbind(chilean$fX1, chilean$fX2),
                              chilean$sX, chilean$inv, chilean$idvar,
                              chilean$timevar, opt='solnp')
    OP.fit.attrition <- prodestOP(chilean$Y, fX = cbind(chilean$fX1, chilean$fX2),
                                chilean$sX, chilean$inv, chilean$idvar,
                                chilean$timevar, exit = TRUE)

    # show results
    summary(OP.fit)
    summary(OP.fit.solnp)

    # show results in .tex tabular format
     printProd(list(OP.fit, OP.fit.solnp, OP.fit.attrition))
}
