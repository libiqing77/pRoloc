\name{lopims}
\alias{lopims}
\title{A complete LOPIMS pipeline}
\usage{
  lopims(hdmsedir = "HDMSE", msedir = "MSE",
    pep3ddir = "pep3D", fastafile, markerfile,
    mfdr = 0.025, ...)
}
\arguments{
  \item{hdmsedir}{A \code{character} identifying the
  directory containing the HDMSe final peptide files.
  Default is \code{HDMSe}.}

  \item{msedir}{A \code{character} identifying the
  directory containing the MSe final peptide files. Default
  is \code{MSe}.}

  \item{pep3ddir}{A \code{character} identifying the
  directory containing the MSe pep 3D files. Default is
  \code{pep3D}.}

  \item{fastafile}{A \code{character} identifying the
  protein fasta database. Default is to use the fasta file
  in the current directory. If several such files exist,
  the function reports an error.}

  \item{markerfile}{A \code{character} identifying the
  marker file (see details for format). Default is to use a
  \code{csv} file starting with \code{marker} in the
  current directory. If several such files exist, the
  function reports an error.}

  \item{mfdr}{The master FDR value. Default is 0.025.}

  \item{...}{Additional paramters passed to
  \code{\link[synapter]{synergise}}.}
}
\value{
  An instance of class \code{"\linkS4class{MSnSet}"} with
  protein level quantitation and respective organelle
  markers.
}
\description{
  The function processes MSe data using the
  \code{\link[synapter]{synergise}} function of the
  \code{\link[synapter]{synapter}} package and combines
  resulting \code{\link[synapter]{Synapter}} instances into
  one \code{"\linkS4class{MSnSet}"} and organelle marker
  data is added as a feature-level annotation variable.
}
\details{
  The \code{LOPIMS} pipeline is composed of 5 steps:
  \enumerate{ \item The HDMSe final peptide files are used
  to compute false discovery rates uppon all possible
  combinations of HDMSe final peptides files and the best
  combination smaller or equal to \code{mfdr} is chosen.
  See \code{\link[synapter]{estimateMasterFdr}} for
  details. The corresponding master run is then created as
  descibed in \code{\link[synapter]{makeMaster}}.

  \item Each MSe/pep3D pair is processed using the HDMSe
  master file using \code{\link[synapter]{synergise}}.

  \item The respective peptide-level \code{synergise}
  output objects are converted and combined into an single
  \code{"\linkS4class{MSnSet}"} instance.

  \item Protein-level quantitation is inferred as follows.
  For each protein, a reference sample/fraction is chosen
  based on the number of missing values (\code{NA}). If
  several samples have a same minimal number of \code{NA}s,
  ties are broken using the sum of counts. The peptide that
  do not display any missing values for each (frac_{i},
  frac_{ref}) pair are summed and the ratio is reported
  (see pRoloc:::refNormMeanOfNonNAPepSum for details).

  \item The markers defined in the \code{markerfile} are
  collated as feature meta-data in the \code{markers}
  variable. See \code{\link{addMarkers}} for details. }

  Intermediate \code{synergise} reports as well as
  resulting objects are stored in a \code{LOPIMS_pipeline}
  directory. For details, please refer to the
  \code{synapter} vignette and reference papers.
}
\author{
  Laurent Gatto
}
\references{
  Improving qualitative and quantitative performance for
  MSE-based label free proteomics. N.J. Bond, P.V. Shliaha,
  K.S. Lilley and L. Gatto, Journal of Proteome Research,
  2013 (in press).

  The Effects of Travelling Wave Ion Mobility Separation on
  Data Independent Acquisition in Proteomics Studies, P.V.
  Shliaha, N.J. Bond, L. Gatto and K.S. Lilley, Journal of
  Proteome Research, 2013 (in press).

  MSnbase-an R/Bioconductor package for isobaric tagged
  mass spectrometry data visualization, processing and
  quantitation. L. Gatto and KS. Lilley. Bioinformatics.
  2012 Jan 15;28(2):288-9. doi:
  10.1093/bioinformatics/btr645. Epub 2011 Nov 22. PubMed
  PMID: 22113085.
}

