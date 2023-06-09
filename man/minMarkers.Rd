\name{minMarkers}
\alias{minMarkers}
\title{Creates a reduced marker variable}
\usage{
  minMarkers(object, n = 10, fcol = "markers")
}
\arguments{
  \item{object}{An instance of class
  \code{"\linkS4class{MSnSet}"}.}

  \item{n}{Minumum of marker instances per class.}

  \item{fcol}{The name of the markers column in the
  \code{featureData} slot. Default is \code{markers}.}
}
\value{
  An instance of class \code{"\linkS4class{MSnSet}"} with a
  new feature variables, named after the original
  \code{fcol} variable and the \code{n} value.
}
\description{
  This function updates an \code{MSnSet} instances and sets
  markers class to \code{unknown} if there are less than
  \code{n} instances.
}
\examples{
library(pRolocdata)
data(dunkley2006)
d2 <- minMarkers(dunkley2006, 20)
getMarkers(dunkley2006)
getMarkers(d2, fcol = "markers20")
}
\author{
  Laurent Gatto
}

