# v0.3

# start
start_time = Sys.time()

# pass arguments
args = commandArgs(trailingOnly=TRUE)

# read config file
config = rjson::fromJSON(file = args[1])
config = rjson::fromJSON(file = './example_data/config.example.json')

# grids
# TODO: The grid library will be replaced by the dials package
source(config$ml.cv$grid.library)

# output
# TODO: find out how relative paths work with nf
file.rds = paste0('./fits/', config$fit.id, '.rds')
file.log = paste0('./fits/', config$fit.id, '.log')

# data
# NOTE: using fread because it's faster
df.data = data.table::fread(config$file.data) %>%
  tibble::column_to_rownames('V1')

# samples
list.samples = read.csv(config$file.samples.train, header = F)$V1

# features
list.features = read.csv(config$file.features, header = F)$V1

# format response variable
if (config$ml.type == 'classification'){
  y = as.factor(df.data[list.samples, config$ml.response])
} else if (config$ml.type == 'regression') {
  y = as.numeric(df.data[list.samples, config$ml.response])
} else {
  stop("ml.type must be of 'classification', 'regression'")
}

# set up trainControl
# TODO: implement other methods such as jackknife, bootstrap, ...
trControl = caret::trainControl(
  method = config$ml.cv$method, 
  number = as.numeric(config$ml.cv$fold), 
  repeats = as.numeric(config$ml.cv$repeats))

# train model
set.seed(as.numeric(config$ml.seed))
cv_model = caret::train(
  y = y, 
  x = df.data[list.samples, list.features, drop=F], 
  method = config$ml.method,
  preProcess = config$ml.preprocess,
  trControl = trControl,
  tuneGrid = list.grids[[config$ml.cv$tune.grid]], # NOTE: if NULL tuneLength is used
  tuneLength = config$ml.cv$tune.length
  )

# ml run time
ml.run_time = 
  cv_model$times$everything['elapsed'] + cv_model$times$final['elapsed']

# save
saveRDS(cv_model, file.rds)
write.table(t(
  data.frame(
    name.out = config$fit.id,
    file.data = config$file.data,
    file.samples.train = config$file.samples.train,
    file.features = config$file.features,
    ml.seed = config$ml.seed,
    ml.method = config$ml.method,
    ml.response = config$ml.response,
    ml.preProcess = config$ml.preprocess,
    ml.fold = config$ml.cv$fold,
    ml.repeats = config$ml.cv$repeats,
    ml.grid = config$ml.cv$tune.grid,
    ml.run_time = ml.run_time,
    note.log = config$note)),
  file.log, row.names = T, quote = F, col.names = F, sep='\t')

# stop
end_time = Sys.time()
run_time = end_time - start_time
print(run_time)
