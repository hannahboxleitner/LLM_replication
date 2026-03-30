# Replication: Mistral Small 3.2 24B Instruct 2506

# With this code, I intended to create a methodological pipeline similar to the one proposed by Morin & Marttinen Larsson (2025). It was already used for replication with another (GPT) model.
# This script contains the conversation with the model, which is divided into pretraining, training and testing of the model, and also contains analysis and evaluation.
# The setup of the model (including API call) and the data import are called here from other R scripts.

# Load setup script
source("LLM_setup.R")

# Load data
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
), MISTRAL)
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
), MISTRAL)
conv <- res$conversation
print(res$answer)

#

# Feedback prompt (1st batch)
res <- ask_llm(conv, paste(
  "#1 is wrong: 1. 'Considering' here means 'taking into account' 2. Insertion test: - 'considering to be its time' doesn't work - 'considering as its time' doesn't work 3. Used to introduce contextual information 4. No evaluative complement 5. Used in sense of 'taking into account' or 'given'",
  "#2 is wrong: 'Considering' here means 'taking into account' 2. Insertion test: - 'considering to be the price' doesn't work - 'considering as the price' doesn't work 3. Used to introduce contextual information 4. No evaluative complement 5. Used in sense of 'taking into account' or 'given'",
  "#6 is wrong: 'considering' means 'taking into account' 2. Used as introduction to factual evidence 3. No evaluation being made",
  "Sentence #7 shows too little context to be sure",
  "#9 is wrong: 1. 'Consider' introduces opinion/conclusion 2. No evaluative complement 3. Used for expressing thought/opinion",
  "#10 is wrong: 'Considering' here means 'taking into account' 2. Insertion test: - 'considering to be the power inside' doesn't work - 'considering as the power inside' doesn't work 3. Used to introduce contextual information 4. No evaluative complement 5. Used in sense of 'taking into account' or 'given'",
  "#14 is wrong: 'Considering' means 'taking into account' 2. introduces historical context 3. no evaluation being made",
  "#17 is wrong: 1. 'Considered for' means 'evaluated for possibility' 2. About contemplation of action 3. No evaluative complement",
  "#20 is wrong: 'considering' introduces contextual information 2. No evaluation being made 3. Simple introduction of fact",
  "#21 is wrong: 1. 'Considered' means 'thought about as option' 2. About contemplation of treatment 3. No evaluation being made",
  "#25 is wrong: 1. 'Considered' means 'thought about' 2. About contemplation of ideas 3. No evaluation being made",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Answer prompt
res <- ask_llm(conv, paste(
  "Yes, please continue with the next batch",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Feedback prompt (about 2nd batch)
res <- ask_llm(conv, paste(
  "#26 is wrong: 1. 'Considered' here means 'examined/thought about' 2. Insertion test: - 'considered to be the proposed spaceport's impacts' doesn't work - 'considered as the proposed spaceport's impacts' doesn't work 3. No evaluative complement 4. About contemplation of impacts",
  "#27 is incorrect: 'considered that as it was sufficient' wouldn't work here. 'that' only works as an evaluative when 'that' is used as a demonstrative pronoun",
  "#28 is wrong: 'consider' means 'think about' 2. Insertion test: 'consider to be who' doesn't work, 'consider as who' doesn't work 3. Request for contemplation 4. No evaluative complement",
  "#31 is wrong: 1. Contains direct complement 'the late late edition' 2. Could insert 'as': 'consider this as the late late edition' 3. Makes classification/evaluation",
  "#35 is wrong: 1. 'Consider' means 'examine/review' 2. Insertion test: 'consider to be the legal options' or 'consider as the legal options doesn't work 3. about contemplation of options",
  "#40 is wrong: 'Considering' here means 'thinking about' 2. Insertion test: - 'worth considering to be' doesn't work - 'worth considering as' doesn't work 3. About contemplation of option",
  "#44 is wrong: 'Considered' here means 'thought about' 2. Insertion test: - 'considered to be: having' doesn't work - 'considered as: having' doesn't work 3. About contemplation of option",
  "#45 is wrong: 1. 'Consider' means 'think about' 2. Insertion test: 'consider to be how' or 'consider as how' doesn't work 3. About contemplation",
  "#47 is wrong: 'consider' means 'think about' 2. About weighing factors 3. No evaluative complement",
  "#48 is wrong: 1. 'Considered' means 'examined/reviewed' 2. Insertion test: 'considered to be in' or 'considered as in' doesn't work 3. About examination of issue",
  "#50 is wrong: 1. 'Considering' means 'thinking about' 2. Insertion test: 'considering to be closing' or 'considering as closing does not work 3. About contemplation of action",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Answer prompt
res <- ask_llm(conv, paste(
  "Yes, continue",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Feedback prompt (about 3rd and 4th batch)
res <- ask_llm(conv, paste(
  "#51 is wrong: 1. Contains evaluative complement 'mandatory' 2. Insertion test: could insert 'as': 'are considered as mandatory' works 3. Makes evaluation of status",
  "#52 is incorrect: 1. contains an 'as' construction 2. makes evaluation of classification/status 3. clear evaluative judgment",
  "#56 is wrong: 1. Contains evaluative complement 'important' 2. Could insert 'as': 'considered as important' works 3. Makes evaluation of quality",
  "#60 is wrong: 1. Contains 'to be' construction 2. Makes evaluation of danger level 3. Clear evaluative judgment",
  "#64 is wrong: 1. Contains evaluative complement 'care workers' 2. Insertion test: Could insert 'as': 'considered as care workers' works 3. Makes evaluation of status/classification",
  "#65 is wrong: 1. Contains direct complement 'a strength' 2. Could insert 'as': 'consider this as a strength' or could also insert 'to be': 'consider this to be a strength' 3. Makes evaluation",
  "#66 is wrong: 1. Contains evaluative complement 'a worthwhile cost' 2. Could insert 'as': 'consider the extra debt as a worthwhile cost' 3. Makes evaluation of value",
  "#67 is wrong: 1. Contains evaluative complement 'safe' 2. Could insert 'as' or also 'to be': 'considered as safe', 'consider to be safe' 3. Makes evaluation of status",
  "#69 is wrong: 1. Contains evaluative complement 'a strike against him' 2. Could insert 'as' or 'to be': 'considered that as a strike against him' / 'considered that to be a strike against him' 3. Makes evaluation ",
  "#71 is wrong: 1. Contains evaluative self-classification 2. Could insert 'as': 'consider myself as a pretty open minded person' 3. Makes evaluation of status",
  "#72 is wrong: 1. Contains evaluative complement 'worthwhile' 2. Could insert 'as': 'consider the cost as worthwhile' 3. Makes evaluation of value",
  "#79 is wrong: 1. Contains evaluative complement 'struggling' 2. Could insert 'as': 'considered as struggling' or even better 'to be': 'considered to be struggling' 3. Makes evaluation of status",
  "#87 is wrong: 1. Contains evaluative complement 'a safe alternative' 2. Could insert 'as': 'considered as a safe alternative' 3. Makes evaluation of safety/suitability",
  "#88 is wrong: 1. Contains evaluative complement 'a party matter' 2. Could insert 'as': 'consider the resolutions as a party matter' 3. Makes evaluation/classification",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Answer prompt
#res <- ask_llm(conv, paste(
  "Yes, continue",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)


# base
res <- ask_llm(conv, paste(
  "",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)