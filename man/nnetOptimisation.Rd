\name{nnetOptimisation}
\alias{nnetOptimisation}
\alias{nnetOptimization}
\alias{nnetRegularisation}
\title{nnet parameter optimisation}
\usage{
  nnetOptimisation(object, fcol = "markers",
    decay = c(0, 10^(-1:-5)), size = seq(1, 10, 2),
    times = 100, test.size = 0.2, xval = 5, fun = mean,
    seed, verbose = TRUE, ...)
}
\arguments{
  \item{object}{An instance of class
  \code{"\linkS4class{MSnSet}"}.}

  \item{fcol}{The feature meta-data containing marker
  definitions. Default is \code{markers}.}

  \item{decay}{The hyper-parameter. Default values are
  \code{c(0, 10^(-1:-5))}.}

  \item{size}{The hyper-parameter. Default values are
  \code{seq(1, 10, 2)}.}

  \item{times}{The number of times internal
  cross-validation is performed. Default is 100.}

  \item{test.size}{The size of test data. Default is 0.2
  (20 percent).}

  \item{xval}{The \code{n}-cross validation. Default is 5.}

  \item{fun}{The function used to summarise the \code{xval}
  macro F1 matrices.}

  \item{seed}{The optional random number generator seed.}

  \item{verbose}{A \code{logical} defining whether a
  progress bar is displayed.}

  \item{...}{Additional parameters passed to
  \code{\link{nnet}} from package \code{nnet}.}
}
\value{
  An instance of class \code{"\linkS4class{GenRegRes}"}.
}
\description{
  Classification parameter optimisation for artificial
  neural network algorithm.
}
\author{
  Laurent Gatto
}
\seealso{
  \code{\link{nnetClassification}} and example therein.
}

