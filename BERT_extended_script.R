# distilBERT: extended analysis with a bigger training set
# This script follows the same approach as in BERT_working_script.R, but with more training data.

## Setup (once every R session)
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

# Import data (from replication of Morin & Marttinen Larssons's study)
source("Data_import.R")

# label mapping
label_map <- c(
  "evaluative" = 0,
  "non-evaluative" = 1,
  "?" = 2
)

## load training data
# pretraining data
df_pretraining <- pretraining_set |>
  select(Sentence, Correct_classifications) |>
  rename(classification = Correct_classifications)

# unsupervised training set 1 + solution labels
df_unsup1 <- unsup_training_set1 |>
  select(id, Sentence) |>
  left_join(
    unsup1_solution |>
      select(id, Classification_Matti),
    by = "id"
  ) |>
  select(Sentence, Classification_Matti) |>
  rename(classification = Classification_Matti)

# unsupervised training set 2 + solution labels
df_unsup2 <- unsup_training_set2 |>
  select(id, Sentence) |>
  left_join(
    unsup2_solution |>
      select(id, classification_Matti),
    by = "id"
  ) |>
  select(Sentence, classification_Matti) |>
  rename(classification = classification_Matti)


# combine all three training datasets into dataframe
df_extended <- bind_rows(
  df_pretraining,
  df_unsup1,
  df_unsup2
)


# convert classifications to numerical labels for DistilBERT
df_extended$label <- as.integer(label_map[df_extended$classification])

# load distilbert
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
  text = df_extended$Sentence,
  label = df_extended$label
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

# Training
training_args <- transformers$TrainingArguments(
  output_dir = "./results_BERT_extended",
  learning_rate = 2e-5,
  per_device_train_batch_size = as.integer(8),
  num_train_epochs = as.integer(3),
  weight_decay = 0.01
)

trainer_extended <- transformers$Trainer(
  model = model,
  args = training_args,
  train_dataset = tokenized_dataset
)

trainer_extended$train()

# Testing
# prepare test data
df_test_extended <- testing_set |>
  select(id, Sentence)

df_test_extended$label <- as.integer(
  label_map[human_gold_standard$Human_classification]
)

# build HF dataset
test_dataset_extended <- datasets$Dataset$from_dict(list(
  text = df_test_extended$Sentence,
  label = df_test_extended$label
))

# tokenize
tokenized_test_extended <- test_dataset_extended$map(
  tokenize_function,
  batched = TRUE
)

# prediction
pred_test_extended <- trainer_extended$predict(
  tokenized_test_extended
)

# Accuracy
preds_test_extended <- apply(pred_test_extended$predictions, 1, which.max) - 1

labels_test_extended <- pred_test_extended$label_ids

accuracy_test_extended <- mean(preds_test_extended == labels_test_extended)

accuracy_test_extended

# Save
writeLines(
  capture.output(sessionInfo()),
  "BERT_extended_transcripts/sessionInfo_BERT_extended.txt"
)
