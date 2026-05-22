# BERT working script
# This script contains: setup (ONCE every session), test, and analysis.

## Setup (once very session)
# load reticulate
library(reticulate)

# activate the correct virtual environment
use_virtualenv("r-transformers", required = TRUE)

# optionally check Python connection
py_config()

# load R packages
#library(text) # if I need it
library(dplyr)
library(ggplot2)

# importing Python module into R (via reticulate)
transformers <- import("transformers", delay_load = TRUE)
datasets <- import("datasets")
torch <- import("torch")

# load tokenizer and model
tokenizer <- transformers$AutoTokenizer$from_pretrained(
  "bert-base-uncased",
  use_fast = TRUE
)

model <- transformers$AutoModelForSequenceClassification$from_pretrained(
  "bert-base-uncased",
  num_labels = as.integer(3)
)

## Test
# Small BERT Test
test_sentence <- "Hello BERT from R!" # test sentence

inputs <- tokenizer(test_sentence, return_tensors = "pt") # tokenize

outputs <- model(
  input_ids = inputs$input_ids,
  attention_mask = inputs$attention_mask
) #run model

outputs$last_hidden_state$shape # check output shape

## Moving on to study data: LLM-replication

# Import data (from replication of Morin & Marttinen Larssons's study)
source("Data_import.R")

