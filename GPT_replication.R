# Replication: OpenAI GPT OSS 120B

# With this code, I intended to create a methodological pipeline similar to the one proposed by Morin & Marttinen Larsson (2025).
# This script contains the conversation with the model, which is divided into pretraining, training and testing of the model, and also contains analysis and evaluation.
# The setup of the model (including API call) and the data import are called here from other R scripts.

# Load setup script
source("LLM_setup.R")

# Load data import script
source("Data_import.R")

# 1. PRETRAINING

# First instruction prompt and pretraining dataset
res <- ask_llm(conv, paste(
  "You’re a research assistant participating in a linguistic research project on syntactic variation in English. You have been asked to perform a high-precision classification task of language data on the use of the verb “consider”. You will classify several sentences as a binary variable: “non-evaluative” or “evaluative” sentence. The goal is to attain at least a 95% classification accuracy on a held-out test set of approximately 100 sentences.",
  "<instructions> Classify sentences containing the verb “consider” as either ‘non-evaluative’ or ‘non-evaluative’. </instructions> Sentences containing evaluative uses of “consider” have the following characteristics:",
  "They consist of someone or something who/that is evaluated in some respect. This can be the syntactic subject, as in these examples: <examples> Lena is considered the best swimmer. Lena is considered to be the best swimmer. Lena is considered as the best swimmer. The patient was considered by the doctors and nurses to be particularly demanding. </examples>. It can also be the direct object, as in the following examples: <examples> They considered Lena the best swimmer. The Nobel committee considered Peruvian world-famous author Mario Vargas Llosa to be the best writer. The members of the board considered the transition to online platforms as imperative for the future of the company. </examples>",
  "The evaluative part of the sentence is a subject or object complement. This complement can be expressed syntactically through three different uses:",
  "1. firstly, the complement can be introduced by “as”, exemplified here: <examples> Considering 2010 as the starting point of the pandemic … . They considered the situation as particularly challenging. She was considered by many as the sole ruler. We also consider matters pertaining to legislation and the penal code as urgent. </examples>",
  "2. Secondly, the complement can be introduced by “to be”, exemplified here: <examples> He will surely be considered by some to be the main authority. They might consider this to be the most viable option available. Consider this to be your last warning. Scientists consider Pluto to be too inhabitable. I consider outsourcing it to be a decent alternative. </examples>.",
  "3. Third, the complement can be introduced directly, without “as” or “to be”: <examples> Brooklyn is not considered part of Manhattan. He considers himself the best at this game. We do not necessarily consider this the last resort. The houses are not considered abandoned property. They consider the contract non-compete. The paintings by Monet were considered impressionistic. </examples>",
  "In ‘non-evaluative’ sentences, the verb “consider” is used to signify “contemplate,” “think about,” and so on. These sentences do not contain an object complement. I exemplify these types of uses in what follows: <examples> They considered the offer, but turned it down. She considered him for the position. Laura was considered for the job. Martin considered that the most obvious solution was the correct one. I will consider it. There are many factors to consider. </examples>",
  "<thinking> When determining if a sentence is evaluative or non-evaluative, think step-by-step, following this stepwise process:",
  "1. Is “consider” (in any form of the verb: “consider,” “considers,” “considering,” “considered”) used with “to be” or “as”?",
  "2. If there is no “to be” or “as”: can “to be” or “as” be inserted and still be grammatically correct? <examples> Do an insertion test: I consider him my best friend. I consider him as my best friend. I consider him to be my best friend. </examples>",
  "3. Is “consider” (in any form of the verb: “consider,” “considers,” “considering,” “considered”) used to indicate evaluating or judgement about someone or something?",
  "4. Is “consider” (in any form) used with object or subject complements, or not? </thinking>",
  "<instructions> <answer> If the answer is yes to any of these questions, classify the sentence as “evaluative”. If the answer is no to these questions, classify the sentence as “non-evaluative.” If you find that a sentence is ambiguous or that the use of “consider” does not clearly fall into either category, classify the sentence as “?” Think step-by-step before assigning a sentence a classification using <thinking> </thinking>, then discard your reasoning. </answer> </instructions>",
  "Pretraining: <instructions> Look at 493 pretraining sentences in the <dataset> Pretraining_data_493.csv </dataset>. Sentences are provided in Column B and the correct classifications in Column C. Think about how the data has been classified. Think about each classification step-by-step, and consider whether you would classify the data in the same way or not. If you have questions or comments, ask them. </instructions>",
  paste(
    apply(pretraining_set, 1, function(row) {
      paste0("Sentence: ", row["Sentence"], " | Label: ", row["Correct_classifications"])
    }),
    collapse = "\n"
  ),
  sep = ""
), GPT)
conv <- res$conversation
print(res$answer)


# 2. SUPERVISED TRAINING (in batches)

# Prompt with data
res <- ask_llm(conv, paste(
  "Training: <instructions> Now we will classify 100 sentences together from the dataset <dataset> Supervised_training_sketchengine_100.csv </dataset>. Work in batches of 25 sentences at a time. Think step-by-step about each classification, and for each classification I want you to include <thinking> </thinking> and your <answer> </answer>. </instructions>",
  paste(
    apply(sup_training_set, 1, function(row) {
      paste0("id: ", row["id"], " | Sentence: ", row["Sentence"])
    }),
    collapse = "\n"
  ), 
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Feedback prompt (1st batch)
res <- ask_llm(conv, paste(
  "Sentence #7 shows too little context to be sure",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Answer prompt
res <- ask_llm(conv, paste(
  "Continue with the next batch", 
sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Next Feedback (2nd batch)
res <- ask_llm(conv, paste(
  "#27 is incorrect: 'considered that as it was sufficient' wouldn't work here. 'that' only works as an evaluative when 'that' is used as a demonstrative pronoun.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# 3rd batch
res <- ask_llm(conv, paste(
  "Please continue with the next batch.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Feedback
res <- ask_llm(conv, paste(
  "#68 is incorrect: 1. 'Considered' introduces a thought/point 2. Insertion test does not work, 3. it is about examining an idea",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Feedback
res <- ask_llm(conv, paste(
  "#82 and #90 are ambiguous.",
  "#95 is incorrect: 1. 'considered' means 'examined/studied', 2. insertion test fails, 3. about examination",
sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# 3. UNSUPERVISED TRAINING

# 3.1 UNSUPERVISED TRAINING 1

# Prompt with data
res <- ask_llm(conv, paste(
  "<instructions> Now you will classify 100 sentences without supervision from the dataset <dataset> Test1_sketchengine_100.csv </dataset>. Think step-by-step for each classification <thinking> </thinking>. The labels available to you are “evaluative,” “non-evaluative,” and “?”. Please provide your classification in tab separated .csv format in one large batch <answer> </answer>. </instructions>",
  "Return ONLY tab-separated values with columns:",
  "id<TAB>Classification",
  "</instructions>",
  paste(
    apply(unsup_training_set1, 1, function(row) {
      paste0("id: ", row["id"], " | Sentence: ", row["Sentence"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Gather feedback for unsupervised training 1
# Read and save model output
tsv_unsup1 <- res$answer |>
  gsub("</?answer>", "", x = _) |>
  trimws()

unsup1_gpt_results <- read_tsv(tsv_unsup1, col_names = c("id", "GPT_classification"))

#ncol(unsup1_gpt_results) # check columns

# Merge and compare accuracy
comparison_unsup1 <- unsup1_solution |>
  left_join(unsup1_gpt_results, by = "id")

accuracy_unsup1 <- mean(
  comparison_unsup1$Classification_Matti == comparison_unsup1$GPT_classification
)

print(accuracy_unsup1)

# Get wrong cases
errors_unsup1 <- comparison_unsup1 |>
  filter(Classification_Matti != GPT_classification)

cat(errors_unsup1$Sentence, sep = "\n")

# Prompt feedback: accuracy and wrong sentences
res <- ask_llm(conv, paste(
  "that resembled my developing aesthetic. </s><s> A few cookbooks kept ending up on top of the pile. </s><s> (If you don't own these books, consider this is an unabashed endorsement.) </s><s> The Canal House series – a favorite of mine since the books first appeared, with
2006 in Telecom Order CRTC 2006-294 and Telecom Order CRTC 2006-295, respectively. </s><s> In these Orders, the Commission considered that CDN and DNA services at DS-1 speed were acceptable as substitute services. </s><s> Reports of a giant monster with glowing
instead continued to introduce beautifully designed products at premium prices. </s><s> So, while I don't view design being considered in all areas of business as a 'new' concept, I am more than encouraged to see international corporations discussing the
allow you admittance to all subjects so your youngster has one spot to go for entertainment only and learning. </s><s> As you consider the free web based learning games accessible, you need to ensure you pick a site that has what your kid needs. </s><s> This",
  "You have reached an accuracy of 96%",
  "Let's review the errors. I have pasted all the sentences you have got wrong",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# 3.2 UNSUPERVISED TRAINING 2

# Prompt
res <- ask_llm(conv, paste(
  "Keep those lessons in mind. I will now give you new data. In your classification, you need to <thinking> Classify step-by-step</thinking> and <instruction> consistently apply insertion test </instruction>",
  "<instructions> Return the full classification in one batch. Return ONLY tab-separated values with columns:",
  "id<TAB>Classification",
  "</instructions>,",
  paste(
    apply(unsup_training_set2, 1, function(row) {
      paste0("id: ", row["id"], " | Sentence: ", row["Sentence"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Gather feedback (only accuracy) for unsupervised training 2
# Read and save output
tsv_unsup2 <- res$answer |>
  gsub("</?answer>", "", x = _) |>
  trimws()

unsup2_gpt_results <- read_tsv(tsv_unsup2, col_names = c("id", "GPT_classification"))

ncol(unsup2_gpt_results) # check if columns are correct

# Merge and compare accuracy
comparison_unsup2 <- unsup2_solution |>
  left_join(unsup2_gpt_results, by = "id")

accuracy_unsup2 <- mean(
  comparison_unsup2$classification_Matti == comparison_unsup2$GPT_classification
)

print(accuracy_unsup2)

# Prompt feedback
res <- ask_llm(conv, paste(
  "You got a 93% accuracy! that is really good.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# 4. TESTING

# Testing prompt and dataset
res <- ask_llm(conv, paste(
  "Now we're proceeding from training and validation to testing. I will provide you with a new dataset. <instructions> Classify the data following the procedure that you have applied successfully in the latest round of classifications.</instructions>",
  "<instructions> Return the full classification in one batch. Return ONLY tab-separated values with columns:",
  "id<TAB>Classification",
  "</instructions>,",
  paste(
    apply(testing_set, 1, function(row) {
      paste0("id: ", row["id"], " | Sentence: ", row["Sentence"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)


# EVALUATION (and final prompt)

# Clean and save model output

tsv_test <- res$answer |>
  gsub("</?answer>", "", x = _) |>
  trimws()

test_gpt_results <- read_tsv(tsv_test, col_names = c("id", "GPT_classification"))

ncol(test_gpt_results) # check number of columns

# Compare with human gold standard annotations and compute accuracy
#human_gold_standard

comparison_test <- human_gold_standard |>
  left_join(test_gpt_results, by = "id")

accuracy_test <- mean(
  comparison_test$Human_classification == comparison_test$GPT_classification
)

print(accuracy_test)

# Get exact number of aligning classifications
aligned_gpt <- sum(
  test_gpt_results$Human_classification == test_gpt_results$GPT_classification,
  na.rm = TRUE
)

print(aligned_gpt)

# Save results as .csv
write_csv2(comparison_test, "replication_data/GPT_replication_results.csv") # put in semicolon separated format for comparison with author's table

# Final prompt
res <- ask_llm(conv, paste(
  "thank you. you have reached a 94% accuracy on an hold-out evaluation test. that's good work.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)


# Pairwise comparison: Cohen's κ
# Load the irr library
library(irr)

# Cohen's κ (2 raters)
cohens_kappa_gpt_human <- kappa2(
  comparison_test[, c("Human_classification", "GPT_classification")]
)

print(cohens_kappa_gpt_human)
