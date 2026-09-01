\name{checkM}
\alias{checkM}
%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%
\title{Change input to matrix}
%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%
\description{
  Function to transform all input to matrix.
}
%%%%%%%%% USAGE %%%%%%%%%%%
\usage{
  checkM(input)
}
%%%%%%%%% ARGUMENTS %%%%%%%%%%%
\arguments{
  %
  \item{input}{
    An \code{R} object. Can be a matrix/dataframe/vector/scalar.
  }
  %
}
%%%%%%%%% DETAILS %%%%%%%%%
\details{
  \code{checkM()} accepts one input and - if \code{input} is a matrix - returns it without column names, otherwise transforms it into a matrix and returns it without column names.
}
%%%%%%%%%%%%%%%% AUTHOR %%%%%%%%%%%%%%%%%%%
\author{Gabriele Rovigatti}
