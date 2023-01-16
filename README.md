# ml-pipeline
nextflow pipeline for ml-based analyses


parameters:

 - fit.id: name of fit for output files
 - file.data: csv file containing all relevant data including response variable - samples on rows, features in columns - comma separated
 - file.features: text file with list of features to include in model training - all features must be included in file.data - items are separated by newline
 - file.samples.train: text file with list of samples to include in model training - all samples must be included in file.data - items are separated by newline
 - ml.type: Basic ml strategy. Must be of value 'classification', 'regression', or 'survival'.
 - ml.response: string identifying response variable. Must be present as column in data file. If ml.type == 'survival' must be of vector length 2 ['status', 'time']. Status: censoring information, Time: time information.
 - ml.method: machine learning model to apply. See https://topepo.github.io/caret/available-models.html for available models.
 - ml.preprocess: list with specification on how data will be pre-processed.
 - ml.seed: seed
 - ml.cv
    method: method for hyperparameter tuning (currently only repeatedcv possible)
    fold: fold split for cross-validation
    repeats: repeats for cross-validation
    grid.library: R file with grid library
    tune.grid: name of grid to use for hyperparameter estimation (preceeds tuneLength). Set to 'none' if tuneLength should be used.
    tune.length: length of tuneGrid
list.samples.test: samples to use for validation in ml_postprocess
note: string with notes