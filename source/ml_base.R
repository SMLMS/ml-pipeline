# v0.3

# start
start_time = Sys.time()

# pass arguments
args = commandArgs(trailingOnly=TRUE)

# read config file
config = rjson::fromJSON(file = args[1])
#config = rjson::fromJSON(file = './example_data/config.example.json')

# grids
source(config$ml.cv$grid.library)

# output
file.rds = paste0('./fits/', config$fit.id, '.rds')
file.log = paste0('./fits/', config$fit.id, '.log')

# data
df.data = read.csv(config$file.data, row.names = 1)

# samples
list.samples = read.csv(config$file.samples.train, header = F)$V1

# features
list.features = read.csv(config$file.features, header = F)$V1

# response
response = config$ml.response

# fit model
set.seed(as.numeric(config$ml.seed))
cv_model = caret::train(
  y = df.data[list.samples, response], 
  x = df.data[list.samples, list.features, drop=F], 
  method = config$ml.method,
  preProcess = eval(parse(text = config$ml.preprocess)),
  trControl = caret::trainControl(
    method = config$ml.cv$method, 
    number = as.numeric(config$ml.cv$fold), 
    repeats = as.numeric(config$ml.cv$repeats)),
  tuneGrid = list.grids[[config$ml.cv$tune.grid]])

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
