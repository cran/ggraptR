curDatasetPlotInputs <- reactive({
  getDefinedPlotInputs(length(numericVars()), length(categoricalVars()))
})

separatePlotInputs <- reactive({
  if (is.null(plotTypes()) || is.null(curDatasetPlotInputs())) return()
  inputs <- lapply(plotTypes(), function(pType) {
    flattenList(isolate(curDatasetPlotInputs()))[[pType]]
  })
  names(inputs) <- plotTypes()
  inputs
})

plotInputs <- reactive({
  unique(unlist(separatePlotInputs()))
})


# to make some numeric features with low n of unique values categorical
nCatUniqVals <- reactive({
  if (is.null(input$nCatUniqVals)) 6 else input$nCatUniqVals
})

# variables for dataset() -- raw or manually aggregated dataset
categoricalVars <- reactive({
  if (is.null(dataset())) return()
  n_uniq_thresh <- isolate(nCatUniqVals())
  rearValFeatures <- getVarNamesUniqValsCntLOEN(dataset(), n_uniq_thresh)
  unique(c(getIsFactorVarNames(dataset()), rearValFeatures))
})

numericVars <- reactive({
  if (is.null(dataset())) return()
  res <- setdiff(colnames(dataset()), categoricalVars())
  if (length(res) != 0) res
})

plotTypesWarn <- reactive({
  if (is.null(dataset())) return()
  n_num <- length(numericVars())
  n_cat <- length(categoricalVars())
  if (n_num == 0) {
    return('Can not draw any plot when number of detected numeric features == 0')
  }
  problem <- if (n_num == 1) {
    'number of detected numeric features == 1' 
  } else if (n_cat == 0) {
    'number of detected categorical features == 0' 
  }
  if (!is.null(problem)) paste('Not all plot types are available for the dataset with',
                               problem)
})

# variables for aggDf()
aggDfFactorVars <- reactive({
  dataset <- aggDf()
  if (!is.null(dataset)) {
    getIsFactorVarNames(dataset)
  }
})

aggDfNumericVars <- reactive({
  dataset <- aggDf()
  if (!is.null(dataset)) {
    getIsNumericVarNames(dataset)
  }
})


# facets
facetWidgetsLoaded <- reactive({
  !any(sapply(c('facetCol', 'facetRow', 'facetWrap','facetScale'), 
              function(widget) is.null(input[[widget]])))
})

isFacetSelected <- reactive({
  if (!facetWidgetsLoaded()) return(F)
  facetFam <- c(facetCol(), facetRow(), facetWrap())
  !(facetFam[1] %in% c('None', '', '.') && length(unique(facetFam)) == 1)
})

facetGridSelected <- reactive({
  facetWidgetsLoaded() && any(c(facetCol(), facetRow()) != '.')
})

facetWrapSelected <- reactive({
  facetWidgetsLoaded() && facetWrap() != '.'
})



# reactive that returns a value "discrete" or "continuous"
xType <- reactive({
  dataset <- aggDf()
  if (!is.null(dataset) && !is.null(x())) {
    if (x() %in% aggDfNumericVars()) 'continuous' else 'discrete'
  }
})


# reactive that returns a value "discrete" or "continuous"
yType <- reactive({
  dataset <- aggDf()
  if (!is.null(dataset) && 'y' %in% plotInputs() && !is.null(y())) {
    if (y() %in% aggDfNumericVars()) 'continuous' else 'discrete'
  }
})

# reactive that returns a value "discrete" or "continuous"
colorType <- reactive({
  dataset <- aggDf()
  if (!is.null(dataset) && !is.null(color())) {
    if (color() %in% aggDfNumericVars()) 'continuous' else 'discrete'
  } else 'none'
})

# conditional reactive: semi-automatic aggregation is on
semiAutoAggOn <- reactive({
  !is.null(plotAggMeth()) && tolower(plotAggMeth()) != 'none'
})
