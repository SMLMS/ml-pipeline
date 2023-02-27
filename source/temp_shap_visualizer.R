library("rjson")
library("tidyverse")
source("./ml_funcs.R")

config_inst <- rjson::fromJSON(file = "./example_data/config.example.regression.json")

# read data
data_df <- data.table::fread(config_inst$file.data) %>%
  tibble::column_to_rownames(config_inst$ml.sampleID) %>%
  as.data.frame()

# read samples
samples_lst <- read.csv(config_inst$file.samples.train, header = FALSE)$V1

# read features
train_features_lst <- read.csv(config_inst$file.features.train, header = FALSE)$V1
n_features <- length(train_features_lst)

# filter data
filtered_df <- data_df[samples_lst,] %>%
  dplyr::mutate(!!as.symbol(config_inst$ml.response) := format_y(!!as.symbol(config_inst$ml.response), config_inst$ml.type)) %>%
  dplyr::select(dplyr::all_of(append(train_features_lst, config_inst$ml.response)))

# load shap class
shap_inst <- readRDS("./fits/shap_interpretation_testFitRegression.rds")
vip_inst <- readRDS("./fits/permutation_interpretation_testFitRegression.rds")

# plot
ggplot2::autoplot(shap_inst)  # Shapley-based importance plot
ggplot2::autoplot(shap_inst, type = "dependence", feature = "wt", X = filtered_df)
ggplot2::autoplot(shap_inst, type = "contribution", row_num = 1)  # explain first row of X
