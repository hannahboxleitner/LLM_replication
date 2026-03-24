# Pilot study: Testing LLM pipeline with sentiment analysis

# In this file, a pilot study based on the approach in Morin & Marttinen Larsson (2025) is conducted, to test out the methodological pipeline with a much smaller dataset.
# The model is used for a classification task as well, but a sentiment analysis with less complex instructions.
# The data used for the pilot was collected and manually annotated for another, older project, which is completely unrelated to this study.


# Load setup script 
source("LLM_setup.R")

# 1. PRETRAINING

# Load data
pretraining_data <- read.csv("pilot_data/pilot_pretraining.csv", stringsAsFactors = FALSE)

# Use ask_llm function for user prompt, including XML-tags
res <- ask_llm(conv, paste(
  "<instructions>",
  "You are a strict emotion classifier.",
  "",
  "IMPORTANT RULES:",
  "1. Pick EXACTLY ONE emotion from this list ONLY: sadness, love, fear, pain, happiness, anger, despair",
  "2. Never pick multiple emotions. Never say 'mixed'. Never say 'none'.",
  "3. If unsure, default to 'neutral' (but neutral is NOT in options, so pick closest).",
  "</instructions>",
  "",
  "<examples>",
  "Example 1: I am feeling very happy today! -> happiness",
  "Example 2: I feel so much pain after the news. -> pain",
  "</examples>",
  sep = ""
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Give the dataset
res <- ask_llm(conv, paste(
  "<instructions>",
  "Look at the pretraining sentences below. Sentences are provided in column A and the correct classifications in column B.",
  "Think about how the data has been classified.",
  "Think about each classification and consider whether you would classify the data in the same way or not.",
  "If you have questions or comments, ask them.",
  "</instructions>",
  paste(
    apply(pretraining_data, 1, function(row) {
      paste0("Sentence: ", row["text"], " | Label: ", row["sentiment"])
    }),
    collapse = "\n"
  ), # generate string from dataset to pass to LLM
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Print transcript of pretraining conversation
# Convert conversation into transcript and save as variable
transcript <- sapply(conv$messages, function(msg) {
  paste0(toupper(msg$role), ": ", msg$content)
})

# Collapse into one big string with line breaks
transcript_text <- paste(transcript, collapse = "\n\n")

# Print to console
cat(transcript_text)
# Save as plain text (and place in pilot folder)
writeLines(transcript_text, "pilot_pretraining_transcript.txt")
file.rename(
  "pilot_pretraining_transcript.txt",
  "pilot_data/pilot_pretraining_transcript.txt"
)

# Also save as JSON (to preserve structure)
write_json(conv, "pilot_data/pilot_pretraining.json", pretty = TRUE, auto_unbox = TRUE)

# 2. SUPERVISED TRAINING

# Load data
supervised_training_data <- read.csv("pilot_data/pilot_supervised_training.csv", stringsAsFactors = FALSE)

# Give the dataset and ask for first batch
res <- ask_llm(conv, paste(
  "<instructions> Now we will classify 15 sentences together from another dataset. Work in batches of 5 sentences at a time. Think step-by-step about each classification, and for each classification I want you to include <thinking> </thinking> and your <answer> </answer>. </instructions>",
  paste(
    apply(supervised_training_data, 1, function(row) {
      paste0("Sentence: ", row["text"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Feedback for first and then next batch
res <- ask_llm(conv, paste(
  "<instructions> Good, these classifications were correct. Please classify the next 5 sentences. </instructions>",
  paste(
    apply(supervised_training_data, 1, function(row) {
      paste0("Sentence: ", row["text"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Feedback for second and then last batch
res <- ask_llm(conv, paste(
  "<instructions> Most classifications were correct, except for \"She don't know how she's supposed to put it from her mind\". Your reasoning is good, but rather points to despair than to pain. Please classify the final 5 sentences. </instructions>",
  paste(
    apply(supervised_training_data, 1, function(row) {
      paste0("Sentence: ", row["text"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
))
conv <- res$conversation
print(res$answer)

# 3. UNSUPERVISED TRAINING

# Load data
unsupervised_training_data <- read.csv("pilot_data/pilot_unsupervised_training.csv", stringsAsFactors = FALSE)

# Give the unsupervised dataset and instruct including format
res <- ask_llm(conv, paste(
  "<instructions>",
  "Now you will classify 16 sentences without supervision.",
  "Think step-by-step for each classification <thinking> </thinking>.",
  "Please provide your classification in tab separated .csv format in one large batch <answer> </answer>.", # looked different
  "</instructions>",
  paste(
    apply(unsupervised_training_data, 1, function(row) {
      paste0("Sentence: ", row["text"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Review the errors (2nd prompt)
res <- ask_llm(conv, paste(
  "<instructions>",
  "had me hopeless and numb </s><s> Weight was more than I was able to bear </s><s> Cause you got no one to listen, you got no one to call </s><s> But I've seen your self-pity showin' as the tears rolled down your cheeks </s><s> Soon you know I'll leave you and I'll never look behind </s><s> My days now end as they began, with thoughts of you </s><s> Now these thoughts are haunting me of how complete I used to be,",
  "your accuracy is 62.5%.",
  "let's review the errors. I have pasted all the classifications that you got wrong.",
  "</instructions>",
  sep = ""
))
conv <- res$conversation
print(res$answer)

# Give feedback with renewed accuracy
res <- ask_llm(conv, paste(
  "<instructions>",
  "your accuracy improved to 100%. that is really good!",
  "</instructions>",
  sep = ""
), MISTRAL)
conv <- res$conversation
print(res$answer)
# Print transcript of conversation
# Convert conversation into transcript and save as variable
#transcript <- sapply(conv$messages, function(msg) {
#  paste0(toupper(msg$role), ": ", msg$content)
#})

# Collapse into one big string with line breaks
#transcript_text <- paste(transcript, collapse = "\n\n")

# Print to console
#cat(transcript_text)
# save as text file
#writeLines(transcript_text, "pilot_data/pilot_training_transcript.txt")


# 4. TESTING

# Load data
testing_data <- read.csv("pilot_data/pilot_testing.csv", stringsAsFactors = FALSE)

# Give the testing dataset and instruct including format
res <- ask_llm(conv, paste(
  "<instructions>",
  "Keep those lessons in mind.",
  "I will now give you new data from the dataset pilot_testing.csv below",
  "Please <thinking> classify each sentence >/thinking>.",
  "Return your results ONLY as a CSV with the columns:",
  "text,sentiment",
  "Put the CSV inside <answer> </answer>.",
  "</instructions>",
  paste(
    apply(testing_data, 1, function(row) {
      paste0("Sentence: ", row["text"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# To judge the output and compare to my annotated dataset, I need to clean the model output first
library(readr)

csv_text <- res$answer |> 
  gsub("</?answer>", "", x = _) |> 
  trimws() # removes <answer> tags from output and replaces with "", removes spaces

llm_results <- read_csv(csv_text) # save results as variable

# Load my annotations
Hannah_annotation <- read_csv("pilot_data/pilot_testing_annotated_Hannah.csv")

# Merge predictions for comparison and name columns (left_join should keep all predictions) ---
comparison <- Hannah_annotation |> 
  left_join(llm_results, by = "text", suffix = c("_human", "_llm"))

# save comparison output for further analysis
write_csv(comparison, "pilot_data/comparison_output.csv")

# Compute accuracy
accuracy <- mean(comparison$sentiment_human == comparison$sentiment_llm)

print(accuracy)

# Write transcript without showing dataset (exchanged with placeholder) - dataset names should be mentioned in prompts for clarity
transcript <- sapply(conv$messages, function(msg) {
  content <- msg$content
  
  # Remove long sentence lists
  content <- sub("Sentence:.*", "[DATASET REMOVED FOR TRANSCRIPT]", content)
  
  paste0(toupper(msg$role), ": ", content)
})

transcript_text <- paste(transcript, collapse = "\n\n")
cat(transcript_text)
writeLines(transcript_text, "pilot_data/pilot_complete.txt")

# Evaluation of inter-rater agreement

#install.packages("irr")
library(irr)

# Cohen's kappa (2 raters)

cohens_kappa <- kappa2(
  comparison[, c("sentiment_human", "sentiment_llm")]
)


cohens_kappa

# Fleiss' kappa (for more than 2 raters, just to try function here)

fleiss_kappa <- kappam.fleiss(
  comparison[, c("sentiment_human", "sentiment_llm")]
)


fleiss_kappa

## maybe save every conversation as json log (for reproducibility purposes)
#write_json(conv$messages, "conversation_log.json", pretty = TRUE)