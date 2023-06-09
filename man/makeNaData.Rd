\name{makeNaData}
\alias{makeNaData}
\alias{makeNaData2}
\alias{whichNA}
\title{Create a data with missing values}
\usage{
  makeNaData(object, nNA, pNA, exclude)

  makeNaData2(object, nRows, nNAs, exclude)

  whichNA(x)
}
\arguments{
  \item{object}{An instance of class \code{MSnSet}.}

  \item{nNA}{The absolute number of missing values to be
  assigned.}

  \item{pNA}{The proportion of missing values to be
  assignmed.}

  \item{exclude}{A \code{vector} to be used to subset
  \code{object}, defining rows that should not be used to
  set \code{NA}s.}

  \item{nRows}{The number of rows for each set.}

  \item{nNAs}{The number of missing values for each set.}

  \item{x}{A \code{matrix} or an instance of class
  \code{MSnSet}.}
}
\value{
  An instance of class \code{MSnSet}, as \code{object}, but
  with the appropriate number/proportion of missing values.
  The returned object has an additional feature meta-data
  columns, \code{nNA}
}
\description{
  These functions take an instance of class
  \code{"\linkS4class{MSnSet}"} and sets randomly selected
  values to \code{NA}.
}
\details{
  \code{makeNaData} randomly selects a number \code{nNA}
  (or a proportion \code{pNA}) of cells in the expression
  matrix to be set to \code{NA}.

  \code{makeNaData2} will select \code{length(nRows)} sets
  of rows from \code{object}, each with \code{nRows[i]}
  rows respectively. The first set will be assigned
  \code{nNAs[1]} missing values, the second \code{nNAs[2]},
  ... As opposed to \code{makeNaData}, this permits to
  control the number of \code{NAs} per rows.

  The \code{whichNA} can be used to extract the indices of
  the missing values, as illustrated in the example.
}
\examples{
## Example 1
library(pRolocdata)
data(dunkley2006)
sum(is.na(dunkley2006))
dunkleyNA <- makeNaData(dunkley2006, nNA = 150)
processingData(dunkleyNA)
sum(is.na(dunkleyNA))
table(fData(dunkleyNA)$nNA)
naIdx <- whichNA(dunkleyNA)
head(naIdx)
## Example 2
dunkleyNA <- makeNaData(dunkley2006, nNA = 150, exclude = 1:10)
processingData(dunkleyNA)
table(fData(dunkleyNA)$nNA[1:10])
table(fData(dunkleyNA)$nNA)
## Example 3
nr <- rep(10, 5)
na <- 1:5
x <- makeNaData2(dunkley2006[1:100, 1:5],
                 nRows = nr,
                 nNAs = na)
processingData(x)
(res <- table(fData(x)$nNA))
stopifnot(as.numeric(names(res)[-1]) ==  na)
stopifnot(res[-1] ==  nr)
## Example 2
nr2 <- c(5, 12, 11, 8)
na2 <- c(3, 8, 1, 4)
x2 <- makeNaData2(dunkley2006[1:100, 1:10],
                  nRows = nr2,
                  nNAs = na2)
processingData(x2)
(res2 <- table(fData(x2)$nNA))
stopifnot(as.numeric(names(res2)[-1]) ==  sort(na2))
stopifnot(res2[-1] ==  nr2[order(na2)])
## Example 5
nr3 <- c(5, 12, 11, 8)
na3 <- c(3, 8, 1, 3)
x3 <- makeNaData2(dunkley2006[1:100, 1:10],
                  nRows = nr3,
                  nNAs = na3)
processingData(x3)
(res3 <- table(fData(x3)$nNA))
}
\author{
  Laurent Gatto
}

