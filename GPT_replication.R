# Replication: OpenAI GPT OSS 120B

# With this code, I intend to create a methodological pipeline similar to the one proposed by Morin & Marttinen Larsson (2025).
# This script contains the conversation with the model, which is divided into pretraining, training and testing of the model, and also contains analysis and evaluation.
# The setup of the model (including API call) and the data import of the data provided by the original authors is to be found in separate scripts, which are called here.

# Load setup script
source("LLM_setup.R")

# Load data import script
source("Data_import.R")

# 1. PRETRAINING

pretraining_set

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

sup_training_set

# Prompt with data
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

unsup_training_set1

# Prompt with data
#res <- ask_llm(conv, paste(
#  "<instructions>",
#  paste(
#    apply(unsup_training_set1, 1, function(row) {
#      paste0("Sentence: ", row["Sentence"])
#    }),
#    collapse = "\n"
#  ), 
#  sep = "\n"
#), GPT)
#conv <- res$conversation
#print(res$answer)

unsup_training_set2


# Prompt


# 4. TESTING

testing_set

# Prompt

# Give the testing dataset and instruct including format
#res <- ask_llm(conv, paste(
#  "<instructions>",
#  "Keep those lessons in mind.",
#  "I will now give you new data from the dataset x below",
#  "Please <thinking> classify each sentence >/thinking>.",
#  "Return your results ONLY as a TSV with the columns:",
#  "Sentence,Classification",
#  "Put the TSV inside <answer> </answer>.",
#  "</instructions>",
#  paste(
#    apply(testing_data, 1, function(row) {
#      paste0("Sentence: ", row["Sentence"])
#    }),
#    collapse = "\n"
#  ),
#  sep = "\n"
#), GPT)
#conv <- res$conversation
#print(res$answer)

# Print clean transcript

# EVALUATION

# Clean model output

#tsv_text <- res$answer |>
#  gsub("</?answer>", "", x = _) |>
#  trimws()

#gpt_results <- read_tsv(tsv_text) |>
#  rename(GPT_classification = Classification) # save results as vraibale and rename column for analysis

# (in other script) human gold standard annotations
human_gold_standard

# Merge predictions for comparison and name columns (left_join should keep all predictions)
#comparison <- human_gold_standard |>
#  left_join(gpt_results, by = "Sentence") # save comparison output for further analysis


#write_csv2(comparison, "NEWFOLDER/x.csv") # put in semicolon separated format for comparison with author's table

# Compute accuracy
#accuracy <- mean(
#  comparison$Human_classification == comparison$GPT_classification
#)

#print(accuracy)