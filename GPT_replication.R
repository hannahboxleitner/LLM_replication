# Replication: OpenAI GPT OSS 120B

# The methodological approach presented by Morin & Marttinen Larsson (2025) is recreated with the code in this script.
# This script contains the conversation, which is divided into pretraining, training and testing of the model, and also contains analysis and evaluation.


# Load setup script
source("LLM_setup.R")

# Load libraries
library(here)


# 1. PRETRAINING

# Load the pretraining data
pretraining_set <- read_csv2(here("data", "Pretraining_data_493.csv"))

# First instruction prompt
#res <- ask_llm(conv, paste(
#  "<instructions>",
#  "</examples>",
#  sep = ""
#), GPT)
#conv <- res$conversation
#print(res$answer)

# Give the pretraining dataset
#res <- ask_llm(conv, paste(
#  "<instructions>",
#  "Look at the pretraining sentences below. Sentences are provided in column A and the correct classifications in column B.",
#  "Think about how the data has been classified.",
#  "Think about each classification and consider whether you would classify the data in the same way or not.",
#  "If you have questions or comments, ask them.",
#  "</instructions>",
#  paste(
#    apply(pretraining_set, 1, function(row) {
#      paste0("Sentence: ", row["Sentence"], " | Label: ", row["Correct_classifications"])
#    }),
#    collapse = "\n"
#  ), 
#  sep = "\n"
#), GPT)
#conv <- res$conversation
#print(res$answer)


# 2. SUPERVISED TRAINING

# Load data for supervised training
sup_training_set <- read_csv2(here("data", "Supervised_training_sketchengine_100.csv"))

# Prompt
#res <- ask_llm(conv, paste(
#  "<instructions>",
#  paste(
#    apply(sup_training_set, 1, function(row) {
#      paste0("Sentence: ", row["Sentence"])
#    }),
#    collapse = "\n"
#  ), 
#  sep = "\n"
#), GPT)
#conv <- res$conversation
#print(res$answer)


# 3. UNSUPERVISED TRAINING

# Load data for unsupervised training (1)
unsup_training_set1 -> 