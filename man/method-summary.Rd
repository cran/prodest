\name{summary}
\alias{summary,prod-method}
\alias{summary}
\docType{methods}
%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%
\title{Print a table with a summary of results}
%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%
\description{
  This method allows the user to print a table with a summary of the results within an \code{S4} \link{prod} object: the parameter estimates, the method, the number of observations, the time elapsed, the number of bootstrap repetitions, the first stage estimates and the starting points.
}
%%%%%%%%%%%%%%%% USAGE %%%%%%%%%%%%%%%%%%%
\usage{
  \S4method{summary}{prod}(object, ...)
}
%%%%%%%%%%%%%%%% ARGUMENTS %%%%%%%%%%%%%%%%%%%
\arguments{
  %
  \item{object}{
    object of class \link{prod}.
  }
  %
  \item{...}{
    Additional arguments.
  }
}
%%%%%%%%%%%%%%%% DETAILS %%%%%%%%%%%%%%%%%%%
\details{
  \code{summary} accepts an \code{S4} \link{prod} object and prints a table with the results.
}
%%%%%%%%%%%%%%%% AUTHOR %%%%%%%%%%%%%%%%%%%
\author{Gabriele Rovigatti}
