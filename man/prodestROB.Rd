\name{prodestROB}
\alias{prodestROB}
\title{
  Estimate productivity - Robinson-Wooldridge method
}
\description{
  The \code{prodestROB()} function accepts at least 6 objects (id, time, output, free, state and proxy variables), and returns a \code{prod} object of class \code{S3} with three elements: (i) a list of model-related objects, (ii) a list with the data used in the estimation and estimated vectors of first-stage residuals, and (iii) a list with the estimated parameters and their bootstrapped standard errors.
}
\usage{
  prodestROB(Y, fX, sX, pX, idvar, timevar, cX = NULL)
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
    the vector/matrix/dataframe identifying individual panels.}
  %
  \item{timevar}{
    the vector/matrix/dataframe identifying time.}
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
    Wooldridge method allows to jointly estimate OP/LP two stages jointly in a system of two equations. It relies on the following set of assumptions:
      \itemize{
        \item a) \eqn{\omega_{it} = g(x_{it} , p_{it})}: productivity is an unknown function \eqn{g(.)} of state and a proxy variables;
\item b) \eqn{E(\omega_{it} | \omega_{it-1)}=f[\omega_{it-1}]}, productivity is an unknown function \eqn{f[.]} of lagged productivity, \eqn{\omega_{it-1}}.
      }
    Under the above set of assumptions, It is possible to construct a system gmm using the  vector of residuals from
    \itemize{
      \item \eqn{r_{1it} = y_{it} - \alpha - w_{it}\beta - x_{it}\gamma - g(x_{it} , p_{it}) }
      \item \eqn{r_{2it} = y_{it} - \alpha - w_{it}\beta - x_{it}\gamma - f[g(x_{it-1} , p_{it-1})]}
    }
    where the unknown function \eqn{f(.)} is approximated by a n-th order polynomial and \eqn{g(x_{it} , m_{it}) = \lambda_{0} + c(x_{it} , m_{it})\lambda}. In particular, \eqn{g(x_{it} , m_{it})} is a linear combination of functions in \eqn{(x_{it} , m_{it})}
    and \eqn{c_{it}} are the addends of this linear combination. The residuals \eqn{r_{it}} are used to set the moment conditions
    \itemize{
      \item \eqn{E(Z_{it}*r_{it}) =0}
    }
    with the following set of instruments:
      \itemize{
        \item \eqn{Z1_{it} = (1, w_{it}, x_{it}, c_{it})}
        \item \eqn{Z2_{it} = (w_{it-1}, c_{it}, c_{it})}
      }
    According to the input timing in ACF, the first equation proposed by Wooldridge would not be useful to identify any of the parameters, but it would be possible to achieve the identification from the second equation by exploiting the orthogonality condition:
      \itemize{
        \item \eqn{\epsilon_{it} | x_{it}, w_{it-1}, x_{it-1}, m_{it-1},...,x_{i1},w_{i1},m_{i1}) = 0}
      }
    with an instrumental variable version of Robinson (1988)'s estimator.
  }


%%%%%%%%% VALUE %%%%%%%%%%%
  \value{
    The output of the function \code{prodestROB} is a member of the \code{S3} class \pkg{prod}. More precisely, is a list (of length 3) containing the following elements:

      \code{Model}, a list containing:
      \itemize{
        \item \code{method:} a string describing the method ('ROB-IV').
        \item \code{elapsed.time:} time elapsed during the estimation.
        \item \code{opt.outcome:} optimization outcome.
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
  \author{
    Gabriele Rovigatti
  }
%%%%%%%%% REFERENCES %%%%%%%%%%%
  \references{
    Ackerberg, D., K. Caves, and G. Frazer (2015).
    "Identification Properties of Recent Production Function Estimators."
    Econometrica 83(6): 2411-2451.

    Robinson, P. M. (1988).
    "Root-N-consistent semiparametric regression."
    Econometrica: Journal of the Econometric Society, 931-954.

    Wooldridge, J M (2009).
    "On estimating firm-level production functions using proxy variables to control for unobservables."
    Economics Letters, 104, 112-114.
  }
%%%%%%%%% EXAMPLES %%%%%%%%%%%
  \examples{
    data("chilean")

    # we fit a model with two free (skilled and unskilled), one state (capital)
    # and one proxy variable (materials)

    ROB.IV.fit <- prodestROB(chilean$Y, fX = cbind(chilean$fX1, chilean$fX2),
                                   chilean$sX, chilean$pX, chilean$idvar, chilean$timevar)

    # show results
    ROB.IV.fit

    \donttest{
      # estimate a panel dataset - DGP1, various measurement errors - and run the estimation
      sim <- panelSim()

      ROB.IV.sim1 <- prodestROB(sim$Y, sim$fX, sim$sX, sim$pX1, sim$idvar, sim$timevar)
      ROB.IV.sim2 <- prodestROB(sim$Y, sim$fX, sim$sX, sim$pX2, sim$idvar, sim$timevar)
      ROB.IV.sim3 <- prodestROB(sim$Y, sim$fX, sim$sX, sim$pX3, sim$idvar, sim$timevar)
      ROB.IV.sim4 <- prodestROB(sim$Y, sim$fX, sim$sX, sim$pX4, sim$idvar, sim$timevar)

      # show results in .tex tabular format
      printProd(list(ROB.IV.sim1, ROB.IV.sim2, ROB.IV.sim3, ROB.IV.sim4),
                parnames = c('Free','State'))
    }
  }
