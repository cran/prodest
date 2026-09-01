\name{lagPanel}
\alias{lagPanel}
%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%
\title{Generate lagged input variables}
%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%
\description{
  Function to generate lagged variables in a panel.
}
%%%%%%%%% USAGE %%%%%%%%%%%
  \usage{
    lagPanel(idvar, timevar, value)
  }
%%%%%%%%% ARGUMENTS %%%%%%%%%%%
  \arguments{
    %
    \item{idvar}{
      vector of panel identifiers.
    }
    %
    \item{timevar}{
      vector of time identifiers.
    }
    %
     \item{value}{
      numeric vector, matrix or data frame containing the variable or variables to be lagged.
    }
    %
  }
%%%%%%%%% DETAILS %%%%%%%%%
  \details{
    \code{lagPanel()} accepts panel identifiers, numeric time identifiers and one or more variables to be lagged. It returns a vector for vector input and a matrix for matrix or data-frame input. Observations without a corresponding value at \eqn{t-1} are returned as \code{NA}. The combination of \code{idvar} and \code{timevar} must uniquely identify observations.
  }
%%%%%%%%%%%%%%%% AUTHOR %%%%%%%%%%%%%%%%%%%
\author{Gabriele Rovigatti}
