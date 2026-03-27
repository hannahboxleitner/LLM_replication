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

sup_training_set

# Prompt with data
res <- ask_llm(conv, paste(
  "Training: <instructions> Now we will classify 100 sentences together from the dataset <dataset> Supervised_training_sketchengine_100.csv </dataset>. Work in batches of 25 sentences at a time. Think step-by-step about each classification, and for each classification I want you to include <thinking> </thinking> and your <answer> </answer>. </instructions>",
  paste(
    apply(sup_training_set, 1, function(row) {
      paste0("Sentence: ", row["Sentence"])
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
  "Sentence #10 you only registered 'Aurora' as a sentence, but this line contains the sentence 'The Aurora R10 chassis is moderately sized, and it could justify being bigger considering the power inside.'",
  "#17 is wrong because 1. 'Considered for' means 'evaluated for possibility' 2. About contemplation of action 3. No evaluative complement",
  "#21 is wrong because 1. 'Considered' means 'thought about as option' 2. About contemplation of treatment 3. No evaluation being made",
  "#25 is wrong because 1. 'Considered' means 'thought about' 2. About contemplation of ideas 3. No evaluation being made",
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
  "Only sentences containing the verb “consider” are relevant for classification, every line is numbered with an id and contains one such sentence. Please stick to the numbering according to the id.", 
  "For example, #26 contains the sentence 'The FAA has not considered the proposed spaceport's impacts on those properties.'",
  "Please classify this batch again.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Next feedback and 3rd batch
res <- ask_llm(conv, paste(
  "#27 is incorrect: 'considered that as it was sufficient' wouldn't work here. 'that' only works as an evaluative when 'that' is used as a demonstrative pronoun.",
  "Your other classifications were correct.",
  "You missed #29 'The above 1839 reference to 'unbridled masturbation...that...ought to be considered [a] species of insanity''",
  "You missed 'The concluding discussion considers patterns in the distribution of complements...' in #42",
  "you missed #48 'whether a public authority may include the costs of maintaining the information in its cost recovery charge to the requester was considered in East Sussex County Council'",
  "you repeated #23 and labeled it #47 in your classifications",
  "Please continue with the next batch. Classify all 'consider'-constructions that occur in batch 51-75 and refer to the id numbering.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Feedback
res <- ask_llm(conv, paste(
  "#68 'let the point be **considered** that it was from good' is incorrect: 1. 'Considered' introduces a thought/point 2. Insertion test does not work, 3. it is about examining an idea",
  "#73 'Researchers **consider** that the concept of a land' is incorrect: 'consider that' introduces a thought/belief and 'that' is used a conjunction, not a demonstartive pronoun",
  "The rest of the classifications are correct.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Last batch
res <- ask_llm(conv, paste(
  "Please continue with the next batch.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# Feedback
res <- ask_llm(conv, paste(
  "#82 and #90 are ambiguous.",
  "#83 is wrong: 'most of the Treaties that will be **considered** in this article' is non-evaluative, it is about examination",
  "You missed #91 '**Considering** this from the perspective of access to education for our members.' The numbering of 91-99 is not consistent with the ids in the dataset",
  "id #93 'For anglo-saxon or non-European investors, the dominant role of the civil code in local business law must be carefully **considered**' is incorrect, is about examination",
  "id #97 'Position... is **considered** while determining' is incorrect: 1. 'considered' means 'taken into account' 2. insertion test fails 3. is about examination.",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# 3. UNSUPERVISED TRAINING

# 3.1 UNSUPERVISED TRAINING 1

# Prompt with data
res <- ask_llm(conv, paste(
  "<instructions> Now you will classify 100 sentences without supervision from the dataset <dataset> Test1_sketchengine_100.csv </dataset>. Think step-by-step for each classification <thinking> </thinking>. The labels available to you are “evaluative,” “non-evaluative,” and “?”. Please provide your classification in tab separated .csv format in one large batch <answer> </answer>. </instructions>",
  "Each row contains multiple sentences separated by </s><s>.",
  "You MUST identify the ONE sentence containing 'consider' and classify it.",
  "",
  "IMPORTANT RULES:",
  "1. Do NOT skip any row.",
  "2. Return EXACTLY one classification per id.",
  "3. The number of output rows MUST equal the number of input rows.",
  "4. Do NOT modify or shorten the id.",
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
  filter(Classification_Matti != Classification)

cat(errors_unsup1$Sentence, sep = "\n")

# Prompt feedback: accuracy and sentences

res <- ask_llm(conv, paste(
  "status of wild relatives is, overall, worse than for birds and mammals generally. </s><s> Whereas 25% of all mammal species are considered threatened with extinction, more than half of mammals that are wild relatives of domesticated mammals are threatened
that resembled my developing aesthetic. </s><s> A few cookbooks kept ending up on top of the pile. </s><s> (If you don't own these books, consider this is an unabashed endorsement.) </s><s> The Canal House series – a favorite of mine since the books first appeared, with
2006 in Telecom Order CRTC 2006-294 and Telecom Order CRTC 2006-295, respectively. </s><s> In these Orders, the Commission considered that CDN and DNA services at DS-1 speed were acceptable as substitute services. </s><s> Reports of a giant monster with glowing
<s> Large animals such as horses or sheep or large numbers of domestic animals, such as a cattery, or a kennel of dogs, are not considered pets. </s><s> Personal Motor Vehicule (PMV) (véhicule automobile personnel - VAP) - for purposes of shipment, means a sedan,
of the people are not neglected or badly treated (Falconer, 2006). </s><s> The criminal justice system has to include or consider the values considered as important by the society. </s><s> Then the social justice system will be implemented through
. </s><s> Hopes For The Next 4 Years: Philadelphia City Official Wishes For Racial Justice </s><s> On Inauguration Day, All Things Considered revisits some of its previous guests to find out what they hope for in the next four years. </s><s> Among them is Philadelphia
allow you admittance to all subjects so your youngster has one spot to go for entertainment only and learning. </s><s> As you consider the free web based learning games accessible, you need to ensure you pick a site that has what your kid needs. </s><s> This
from problem formulation to overall risk estimation. </s><s> On-line forum and AHTEG experts tried to cover all 'points to consider' which could be relevant to RA process and helpful for risks' estimation and evaluation, and Parties to the Protocol",
  "You have reached an accuracy of 92%",
  "Let's review the errors. I have pasted all the sentences you have got wrong",
  sep = "\n"
), GPT)
conv <- res$conversation
print(res$answer)

# 3.2 UNSUPERVISED TRAINING 2

# Prompt
res <- ask_llm(conv, paste(
  "Keep those lessons in mind. I will now give you new data. In your classification, you need to <thinking> Classify step-by-step</thinking> and <instruction> consistently apply insertion test </instruction>",
  "Each row contains multiple sentences separated by </s><s>. <Instructions> You MUST identify the ONE sentence containing 'consider' and classify it.",
  "IMPORTANT RULES:",
  "1. Do NOT skip any row.",
  "2. Return EXACTLY one classification per id.",
  "3. The number of output rows MUST equal the number of input rows.",
  "4. Do NOT modify or shorten the id.",
  "Return ONLY tab-separated values with columns:",
  "id<TAB>Classification",
  "</instructions>",
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

# define classification labels again

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
#  "id,GPT_classification",
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

# Clean and save model output

#tsv_text <- res$answer |>
#  gsub("</?answer>", "", x = _) |>
#  trimws()

#gpt_results <- read_tsv(tsv_text) |>
#  rename(GPT_classification = Classification) # save results as vraibale and rename column for analysis

# ncol(gpt_results) # check number of columns

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