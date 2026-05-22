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

# Fine-tuning distilbert (with pretraining dataset)

# load data
# only columns that are needed
df <- pretraining_set |> 
  select(Sentence, Correct_classifications)

# label mapping
label_map <- c(
  "evaluative" = 0,
  "non-evaluative" = 1,
  "?" = 2
)

df$label <- as.integer(label_map[df$Correct_classifications])

# switch to distilbert
tokenizer <- transformers$AutoTokenizer$from_pretrained(
  "distilbert-base-uncased",
  use_fast = TRUE
)

model <- transformers$AutoModelForSequenceClassification$from_pretrained(
  "distilbert-base-uncased",
  num_labels = as.integer(3)
)

# Convert data to huggingface dataset
dataset <- datasets$Dataset$from_dict(list(
  text = df$Sentence,
  label = df$label
))

# Tokenization
tokenize_function <- function(example) {
  tokenizer(
    example[["text"]],
    truncation = TRUE,
    padding = "max_length",
    max_length = as.integer(128)
  )
}

tokenized_dataset <- dataset$map(tokenize_function, batched = TRUE)

# Training arguments
training_args <- transformers$TrainingArguments(
  output_dir = "./results",
  learning_rate = 2e-5,
  per_device_train_batch_size = as.integer(8),
  num_train_epochs = as.integer(3),
  weight_decay = 0.01
)

# Train
trainer <- transformers$Trainer(
  model = model,
  args = training_args,
  train_dataset = tokenized_dataset
)

trainer$train()
