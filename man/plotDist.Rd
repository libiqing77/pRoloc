\name{plotDist}
\alias{plotDist}
\title{Plots the distribution of features across fractions}
\usage{
  plotDist(object, markers, mcol = "steelblue",
    pcol = "grey90", alpha = 0.3, fractions, ...)
}
\arguments{
  \item{object}{An instance of class \code{MSnSet}.}

  \item{markers}{A \code{character}, \code{numeric} or
  \code{logical} of appropriate length and or content used
  to subset \code{object} and define the organelle
  markers.}

  \item{mcol}{A \code{character} define the colour of the
  marker features. Default is \code{"steelblue"}.}

  \item{pcol}{A \code{character} define the colour of the
  non-markers features. Default is \code{"grey90"}.}

  \item{alpha}{A numeric defining the alpha channel
  (transparency) of the points, where \code{0 <= alpha <=
  1}, 0 and 1 being completely transparent and opaque.}

  \item{fractions}{An optional \code{character} defining
  the \code{phenoData} variable to be used to label the
  fraction along the x axis. If missing, the
  \code{phenoData} variables are searched for a match to
  \code{fraction}. If no match is found, the fractions are
  labelled as numericals.}

  \item{...}{Additional parameters passed to
  \code{\link{plot}}.}
}
\value{
  Used for its side effect of producing a feature
  distribution plot. Invisibly returns \code{NULL}.
}
\description{
  Produces a line plot showing the feature abundances
  across the fractions.
}
\examples{
library("pRolocdata")
data(tan2009r1)
j <- which(fData(tan2009r1)$markers == "mitochondrion")
i <- which(fData(tan2009r1)$PLSDA == "mitochondrion")
plotDist(tan2009r1[i, ],
         markers = featureNames(tan2009r1)[j],
         main = "Mitochondrion")
}
\author{
  Laurent Gatto
}

