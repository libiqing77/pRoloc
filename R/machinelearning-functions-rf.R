##' Classification parameter optimisation for the random forest algorithm.
##' 
##' @title svm parameter optimisation
##' @param object An instance of class \code{"\linkS4class{MSnSet}"}.
##' @param fcol The feature meta-data containing marker definitions.
##' Default is \code{markers}.
##' @param mtry The hyper-parameter. Default value is \code{NULL}.
##' @param times The number of times internal cross-validation is performed.
##' Default is 100.
##' @param test.size The size of test data. Default is 0.2 (20 percent).
##' @param xval The \code{n}-cross validation. Default is 5.
##' @param fun The function used to summarise the \code{xval} macro F1 matrices.
##' @param seed The optional random number generator seed.
##' @param verbose A \code{logical} defining whether a progress bar is displayed.
##' @param ... Additional parameters passed to \code{\link{randomForest}} from package \code{randomForest}.
##' @return An instance of class \code{"\linkS4class{GenRegRes}"}.
##' @seealso \code{\link{rfClassification}} and example therein.
##' @aliases rfRegularisation rfOptimization
##' @author Laurent Gatto
rfOptimisation <- function(object,
                           fcol = "markers",
                           mtry = NULL,
                           times = 100,
                           test.size = .2,
                           xval = 5,                               
                           fun = mean,
                           seed,
                           verbose = TRUE,
                           ...) {
  
  nparams <- 1 ## 2 or 1, depending on the algorithm
  mydata <- subsetAsDataFrame(object, fcol, train = TRUE)

  if (missing(seed)) {
    seed <- sample(.Machine$integer.max, 1)
  }
  .seed <- as.integer(seed)  
  set.seed(.seed)

  if (is.null(mtry)) {
    ## See ?randomForest and 
    ## Breiman, L (2002), "Manual On Setting Up, Using, And
    ## Understanding Random Forests V3.1"",
    ## <URL: http://oz.berkeley.edu/users/breiman/Using_random_forests <- V3.1.pdf>.
    suggested_mtry <- ceiling(sqrt(ncol(mydata)))
    from_mtry <- floor(suggested_mtry/2)
    to_mtry <- 2 * suggested_mtry
    mtry <- as.integer(seq(from_mtry, to_mtry, length.out = 9))
    mtry <- sort(unique(c(mtry, suggested_mtry)))
  } 
  
  ## initialise output
  .warnings <- NULL
  .f1Matrices <- vector("list", length = times)
  .testPartitions <- .cmMatrices <- vector("list", length = times) ## NEW
  .results <- matrix(NA, nrow = times, ncol = nparams + 1)
  colnames(.results) <- c("F1", "mtry") 
  
  if (verbose) {
    pb <- txtProgressBar(min = 0,
                         max = xval * times,
                         style = 3)
    ._k <- 0
  }
  for (.times in 1:times) {
    .size <- ceiling(table(mydata$markers) * test.size)
    ## size is ordered according to levels, but strata
    ## expects them to be ordered as they appear in the data
    .size <- .size[unique(mydata$markers)] 
    test.idx <- strata(mydata, "markers",
                       size = .size,
                       method = "srswor")$ID_unit    
    .testPartitions[[.times]] <- test.idx ## NEW
    
    .test1   <- mydata[ test.idx, ] ## 'unseen' test set
    .train1  <- mydata[-test.idx, ] ## to be used for parameter optimisation
    
    xfolds <- createFolds(.train1$markers, xval, returnTrain = TRUE)
    ## stores the xval F1 matrices
    .matrixF1L <- vector("list", length = xval)  

    for (.xval in 1:xval) {    
        if (verbose) {
          setTxtProgressBar(pb, ._k)
          ._k <- ._k + 1
        }
        .train2 <- .train1[ xfolds[[.xval]], ]
        .test2  <- .train1[-xfolds[[.xval]], ]    

        ## The second argument in makeF1matrix will be
        ## used as rows, the first one for columns
        .matrixF1 <- makeF1matrix(list(mtry = mtry))
        ## grid search for parameter selection
          for (.mtry in mtry) {
            model <- randomForest(markers ~ ., .train2, mtry = .mtry, ...)            
            ans <- randomForest:::predict.randomForest(model, .test2, type = "response") 
            conf <- confusionMatrix(ans, .test2$markers)$table
            .p <- checkNumbers(MLInterfaces:::.precision(conf))
            .r <- checkNumbers(MLInterfaces:::.recall(conf))
            .f1 <- MLInterfaces:::.macroF1(.p, .r)
            .matrixF1[1, as.character(.mtry)] <- .f1
          }
        ## we have a complete grid to be saved
        .matrixF1L[[.xval]] <- .matrixF1
      }
    ## we have xval grids to be summerised
    .summaryF1 <- summariseMatList(.matrixF1L, fun)
    .f1Matrices[[.times]] <- .summaryF1
    .bestParams <- getBestParams(.summaryF1)[1:nparams, 1] ## take the first one
    model <- randomForest(markers ~ ., .train1, mtry = .bestParams["mtry"], ...)
    ans <- randomForest:::predict.randomForest(model, .test1, type = "response") 
    conf <- confusionMatrix(ans, .test1$markers)$table
    .cmMatrices[[.times]] <- conf <- confusionMatrix(ans, .test1$markers)$table ## NEW
    p <- checkNumbers(MLInterfaces:::.precision(conf),
                       tag = "precision", params = .bestParams)
    r <- checkNumbers(MLInterfaces:::.recall(conf),
                       tag = "recall", params = .bestParams)
    f1 <- MLInterfaces:::.macroF1(p, r) ## macro F1 score for .time's iteration
    .results[.times, ] <- c(f1, .bestParams["mtry"])
  }
  if (verbose) {
    setTxtProgressBar(pb, ._k)
    close(pb)
  }
  
  .hyperparams <- list(mtry = mtry)
  .design <- c(xval = xval,
               test.size = test.size,
               times = times)
 
  ans <- new("GenRegRes",
             algorithm = "randomForest",
             seed = .seed,
             hyperparameters = .hyperparams,
             design = .design,
             results = .results,
             f1Matrices = .f1Matrices,
             cmMatrices = .cmMatrices, ## NEW
             testPartitions = .testPartitions, ## NEW
             datasize = list(
               "data" = dim(mydata),
               "data.markers" = table(mydata[, "markers"]),
               "train1" = dim(.train1),
               "test1" = dim(.test1),
               "train1.markers" = table(.train1[, "markers"]),
               "train2" = dim(.train2),
               "test2" = dim(.test2),
               "train2.markers" = table(.train2[, "markers"])))
  
  if (!is.null(.warnings)) {
    ans@log <- list(warnings = .warnings)
    sapply(.warnings, warning)
  }
  return(ans)
}

rfOptimization <-
  rfOptimisation

rfRegularisation <- function(...) {
  .Deprecated(msg = "This function has been replaced by 'rfOptimisation'.")
  rfOptimisation(...)  
}



##' Classification using the random forest algorithm.
##'
##' @title rf classification
##' @param object An instance of class \code{"\linkS4class{MSnSet}"}.
##' @param assessRes An instance of class \code{"\linkS4class{GenRegRes}"},
##' as generated by \code{\link{rfOptimisation}}.
##' @param scores One of \code{"prediction"}, \code{"all"} or \code{"none"}
##' to report the score for the predicted class only, for all cluster
##' or none.
##' @param mtry If \code{assessRes} is missing, a \code{mtry} must be provided.
##' @param fcol  The feature meta-data containing marker definitions.
##' Default is \code{markers}.
##' @param ... Additional parameters passed to \code{\link{randomForest}} from package \code{randomForest}.
##' @return An instance of class \code{"\linkS4class{MSnSet}"} with
##' \code{rf} and \code{rf.scores} feature variables storing the
##' classification results and scores respectively.
##' @author Laurent Gatto
##' @aliases rfPrediction
##' @examples
##' library(pRolocdata)
##' data(dunkley2006)
##' ## reducing parameter search space and iterations 
##' params <- rfOptimisation(dunkley2006, mtry = c(2, 5, 10),  times = 3)
##' params
##' plot(params)
##' f1Count(params)
##' levelPlot(params)
##' getParams(params)
##' res <- rfClassification(dunkley2006, params)
##' getPredictions(res, fcol = "rf")
##' getPredictions(res, fcol = "rf", t = 0.75)
##' plot2D(res, fcol = "rf")
rfClassification <- function(object,
                             assessRes,
                             scores = c("prediction", "all", "none"),
                             mtry,
                             fcol = "markers",
                             ...) {
  scores <- match.arg(scores)  
  if (missing(assessRes)) {
    if (missing(mtry))
      stop("First run 'rfOptimisation' or set 'mtry' manually.")
    params <- c("mtry" = mtry)
  } else {
    params <- getParams(assessRes)
    if (is.na(params["mtry"]))
      stop("No 'mtry' found.")
  }
  trainInd <- which(fData(object)[, fcol] != "unknown")
  form <- as.formula(paste0(fcol, " ~ ."))
  ans <- MLearn(form, t(object), randomForestI, trainInd,
                mtry = params["mtry"],
                ...)
  fData(object)$rf <- predictions(ans)
  if (scores == "all") {
    scoreMat <- predScores(ans)
    colnames(scoreMat) <- paste0(colnames(scoreMat), ".rf.scores")
    fData(object) <- cbind(fData(object), scoreMat)
  } else if (scores == "prediction") {
    fData(object)$rf.scores <- predScore(ans)
  } ## else scores is "none" 
  object@processingData@processing <- c(processingData(object)@processing,
                                        paste0("Performed random forest prediction (", 
                                               paste(paste(names(params), params, sep = "="),
                                                     collapse = " "), ") ",
                                               date()))
  if (validObject(object))
    return(object)
}

rfPrediction <- function(...) {
  .Deprecated(msg = "This function has been replaced by 'rfClassification'.")
  rfClassification(...)
}
