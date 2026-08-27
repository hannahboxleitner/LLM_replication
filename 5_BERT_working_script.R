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

## Validation 1
# prepare data
df_eval1 <- unsup_training_set1 |>
  select(id, Sentence) # extract sentences

df_eval1$label <- as.integer(label_map[unsup1_solution$Classification_Matti]) # attach labels from solution file

# Build Huggingface dataset
eval_dataset1 <- datasets$Dataset$from_dict(list(
  text = df_eval1$Sentence,
  label = df_eval1$label
))

# Tokenize
tokenize_function <- function(example) {
  tokenizer(
    example[["text"]],
    truncation = TRUE,
    padding = "max_length",
    max_length = as.integer(128)
  )
}

tokenized_eval1 <- eval_dataset1$map(tokenize_function, batched = TRUE)

# Prediction with trained model
pred1 <- trainer$predict(tokenized_eval1)

#Compute accuracy
preds <- apply(pred1$predictions, 1, which.max) - 1
labels <- pred1$label_ids

accuracy_eval1 <- mean(preds == labels)
accuracy_eval1

## Validation 2
# prepare data
df_eval2 <- unsup_training_set2 |>
  select(id, Sentence)

df_eval2$label <- as.integer(label_map[unsup2_solution$classification_Matti])

# check alignment
# all(unsup_training_set2$id == unsup2_solution$id)

# build HF dataset
eval_dataset2 <- datasets$Dataset$from_dict(list(
  text = df_eval2$Sentence,
  label = df_eval2$label
))

# tokenize
tokenized_eval2 <- eval_dataset2$map(tokenize_function, batched = TRUE)

# run prediction
pred2 <- trainer$predict(tokenized_eval2)

# Accuracy
preds2 <- apply(pred2$predictions, 1, which.max) - 1
labels2 <- pred2$label_ids

accuracy_eval2 <- mean(preds2 == labels2)
accuracy_eval2

# Testing
#Load data
df_test <- testing_set |>
  select(id, Sentence)

df_test$label <- as.integer(label_map[human_gold_standard$Human_classification])

# HF dataset
test_dataset <- datasets$Dataset$from_dict(list(
  text = df_test$Sentence,
  label = df_test$label
))

# tokenize
tokenized_test <- test_dataset$map(tokenize_function, batched = TRUE)

# prediction
pred_test <- trainer$predict(tokenized_test)

# Accuracy
preds_test <- apply(pred_test$predictions, 1, which.max) - 1
labels_test <- pred_test$label_ids

accuracy_test <- mean(preds_test == labels_test)
accuracy_test

# Save
writeLines(capture.output(sessionInfo()), "sessionInfo_BERT.txt")
