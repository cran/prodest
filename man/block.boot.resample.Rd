\name{block.boot.resample}
\alias{block.boot.resample}
%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%
\title{Cluster Bootstrap Resampling}
%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%
\description{
  Generate row indices for an individual-level block bootstrap of panel data.
  All observations belonging to a sampled individual are kept together.
}
%%%%%%%%% USAGE %%%%%%%%%%%
\usage{
  block.boot.resample(idvar, R)
}
%%%%%%%%% ARGUMENTS %%%%%%%%%%%
\arguments{
  \item{idvar}{
    One-column vector, matrix or data frame of panel identifiers. Numeric,
    character and factor labels are accepted.
  }
  \item{R}{
    Positive integer giving the number of bootstrap samples.
  }
}
%%%%%%%%% DETAILS %%%%%%%%%
\details{
  For every replication, the function samples the distinct panel identifiers
  with replacement. It returns a list of one-column integer matrices. Matrix
  values are row positions in the original data, while row names are newly
  generated sequential identifiers for the resampled panels. Consequently, a
  source panel may be selected more than once without merging its copies.
}
%%%%%%%%% VALUE %%%%%%%%%
\value{
  A list of length \code{R}. Each element is a one-column integer matrix of
  resampled row positions with bootstrap panel identifiers stored as row names.
}
%%%%%%%%%%%%%%%% AUTHOR %%%%%%%%%%%%%%%%%%%
\author{Gabriele Rovigatti}
