\name{checkMD}
\alias{checkMD}
%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%
\title{Change dummy input to dummy matrix}
%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%
\description{
  Function to transform all input to a matrix. In addition, it checks whether all elements of the input are either 0 or 1.
}
%%%%%%%%% USAGE %%%%%%%%%%%
  \usage{
    checkMD(input)
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
    \code{checkMD()} accepts one input and - if \code{input} is a matrix - returns it without column names, otherwise transforms it into a matrix and returns it without column names. In case any of the elements of input are different from 0 or 1, it stops the routine and throws an error.
  }
%%%%%%%%%%%%%%%% AUTHOR %%%%%%%%%%%%%%%%%%%
\author{Gabriele Rovigatti}
