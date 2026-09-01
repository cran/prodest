\name{gACF}
\alias{gACF}
%%%%%%%%%%%%%%%% TITLE %%%%%%%%%%%%%%%%%%%
\title{ACF Second Stage - GMM estimation}
%%%%%%%%%%%%%%%% DESCRIPTION %%%%%%%%%%%%%%%%%%%
\description{
  \code{gACF} returns the second stage parameters estimates of ACF models. It is part of the \code{prodestACF()} routine.
}
%%%%%%%%% USAGE %%%%%%%%%%%
  \usage{
    gACF(theta, mZ, mW, mX, mlX, vphi, vlag.phi)
  }
%%%%%%%%% ARGUMENTS %%%%%%%%%%%
  \arguments{
    %
    \item{theta}{
      Vector of parameters to be estimated.
    }
    %
    \item{mZ}{
      Matrix of instruments.
    }
    %
    \item{mW}{
      Weighting matrix.
    }
    %
    \item{mX}{
      Matrix of regressors.
    }
    %
    \item{mlX}{
      matrix of lagged regressors.
    }
    %
    \item{vphi}{
      Vector of fitted polynomial.
    }
    %
    \item{vlag.phi}{
      Lagged vector of fitted polynomial.
    }
    %
  }
%%%%%%%%% DETAILS %%%%%%%%%
  \details{
    \code{gACF()} estimates the second stage of ACF routine. It accepts 7 inputs, generates and optimizes over the group of moment functions \eqn{E(\xi_{it} Z^k_{it})}{E(xi_it Z_it^k)}.
  }
%%%%%%%%%%%%%%%% AUTHOR %%%%%%%%%%%%%%%%%%%
\author{Gabriele Rovigatti}
