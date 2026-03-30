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
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Gather feedback for unsupervised training 1
# Read and save model output: Needed to be adjusted because of formatting issues in model output
tsv_unsup1 <- res$answer |>
  gsub("</?answer>", "", x = _) |>  
  gsub("```", "", x = _) |>          # remove code block markers
  trimws() |>
  gsub(" {2,}", "\t", x = _)         # convert spaces to tabs

# remove any lines before the headers/keep only header and rows starting with a number
lines <- strsplit(tsv_unsup1, "\n")[[1]]
table_lines <- lines[grep("^(id|[0-9])", lines)]
tsv_clean <- paste(table_lines, collapse = "\n")

# read as TSV and save as variable
unsup1_mistral_results <- read_tsv(I(tsv_clean))

# rename second column (for consistency)
names(unsup1_mistral_results)[2] <- "Mistral_classification"

#ncol(unsup1_mistral_results) # check columns

# Merge and compare accuracy
comparison_unsup1 <- unsup1_solution |>
  left_join(unsup1_mistral_results, by = "id")

accuracy_unsup1 <- mean(
  comparison_unsup1$Classification_Matti == comparison_unsup1$Mistral_classification
)

print(accuracy_unsup1)

# Get wrong cases
errors_unsup1 <- comparison_unsup1 |>
  filter(Classification_Matti != Mistral_classification)

cat(errors_unsup1$Sentence, sep = "\n")


# Prompt feedback: accuracy and wrong sentences
res <- ask_llm(conv, paste(
  "adopted, would essentially create a firearm or weapons exception to the Fourth Amendment. </s><s> This sweeping argument was considered by the Florida Supreme Court and was correctly rejected. </s><s> The purpose of a police stop and frisk is to prevent criminal
<s> Some possible starting points are described in the getting started section. </s><s> early to rise </s><s> Hear from Craig and people he considers to be the wisest, most successful, all-round people in the world, with both great personal and professional lives. </s>
water in Kirkuk. </s><s> The climate of Kirkuk is semi-arid with cold rainy winter and hot dry summer. </s><s> Floods caused by rain are considered as the main source of Kirkuk's groundwater despite the availability of surface water. </s><s> (Al-Tameemi, 2020, S. 2) </s><s> 
to my only friends here, Karen and Mike. </s><s> I told her how wonderful I thought that Grandma was, and that I had told her that I considered her part of my family. </s><s> I wanted very much for Mother to meet her, and I hoped that they would be friends. </s><s> I went back to my
[6], and a few cases of immediate-type allergy to Goji berries were recently reported in Spain [12,13]. </s><s> While LTP is considered responsible for the reactions [12], our data suggest that other allergens, such as high-molecular-weight allergens
Froman, representing the Obama Administration, vetoed the ban. </s><s> In a letter explaining the veto, Froman said he considered the potential harm the sales ban would cause to consumers (limiting consumer choice) and the U.S. economy. </s><s> The
Korea. </s><s> The so-called Iran Nuclear Deal is an example of hard diplomatic efforts that led to an agreement which is widely considered successful. </s><s> While the context between Iran and North Korea is quite different, the fact that hostile nations were able
with the newest safety features available. </s><s> Remember, some of these features may be optional. </s><s> As I said earlier, I consider stability control to be a 'must have' feature. </s><s> And, since stability control depends upon the computer and wheel
the wet field where rice is planted, but in South Asia it is used to refer to the rice itself. </s><s> Brown rice and rice gruel, considered by some to be fit only for poor people, is called by the Chinese word, congee. </s><s> The Female Grain </s><s> Rabinowitz tells us that in
status of wild relatives is, overall, worse than for birds and mammals generally. </s><s> Whereas 25% of all mammal species are considered threatened with extinction, more than half of mammals that are wild relatives of domesticated mammals are threatened
version 5.42. </s><s> Happy Holidays Dexter and Quade. </s><s> Version 5.50 Release Candidate... </s><s> We fixed the remaining issues we considered to be critical and are making this build available as a possible release candidate. </s><s> The download link and more details
processes. </s><s> A false feeling of well being exists, because the pituitary gland is over-stimulated. </s><s> This gland is considered the master gland because it sends hormones to the other glands...the thyroid, adrenals, reproductive glands, and the
spend money addressing bovine TB? </s><s> Why is it necessary to spend money addressing bovine TB when bovine TB is currently considered to be a very small risk to human health? </s><s> Prof Christl Donnelly replied to this on the BBC's Farming Live program on 28th
descriptors, each eight bytes in length. </s><s> The IDT is created and maintained by the operating system and is thus considered a CPU data structure, but it also falls under the control of the operating system. </s><s> If the operating system messes up the
, in spite of the insistence of the Mexican officers; and that they proceeded to take an official record of the event and considered the act finished. </s><s> 41. </s><s> At no time was the Commission informed of the grounds for considering this person as the probable
  Christian. </s><s> We destroy the moral standing of the bible and Christianity and that is the real heresy and blasphemy. </s><s> We may consider it Christian and biblical to condemn what we see as the sin of homosexuality but we bring judgment on ourselves to be
  you with your vicious companion? </s><s> Again no answer, but inward and increasing annoyance, of which Mr. Bellingham considered Ruth the cause. </s><s> At length he spoke-- </s><s> Mother, you are not helping me in my difficulty. </s><s> I have no desire to banish you, nor
  instead continued to introduce beautifully designed products at premium prices. </s><s> So, while I don't view design being considered in all areas of business as a 'new' concept, I am more than encouraged to see international corporations discussing the
of the people are not neglected or badly treated (Falconer, 2006). </s><s> The criminal justice system has to include or consider the values considered as important by the society. </s><s> Then the social justice system will be implemented through
. </s><s> Parayana Krama (Prescribed Methods of Reading/Chanting) </s><s> Devi Mahatmya is a story but each of its slokas are considered to be mantras. </s><s> There are two methods of how to start reading Devi Mahatmya. </s><s> The first one is called Tryangam and consists
ADA's 'business necessity' standard. </s><s> Consistent with the ADA standard, employers should ensure that the tests are considered accurate and reliable. </s><s> For example, employers may review information from the U.S. Food and Drug Administration
  of the new. </s><s> FACUA-Consumers in Action hopes that the Government open an investigation about that facts. </s><s> FACUA considers it unacceptable that the Minister of Public works does not accomodate consumer associations in their coordination
  . </s><s> The Supreme Court is supposed to decide on who can build on it. </s><s> Both religions consider it sacred. </s><s> (6:43) </s><s> All Things Considered , June 24, 1998, Moscow Business -- NPR's Anne Garrels reports on the new Moscow -- a glitzy metropolis of foreign cars,
there is some controversy regarding whether the canine split products produce acceptable pain relief. </s><s> It should be considered an adjunct to supplement more reliable pain relievers in this species. </s><s> This medication helps reduce what is called 
measure. </s><s> [1, 2] Dunn's driving on the shoulder for a thousand feet and shouting to Sullivan may or may not be considered as creating an emergency of the same duration, but, in any event, the peril was not one created by Dunn alone without
  allow you admittance to all subjects so your youngster has one spot to go for entertainment only and learning. </s><s> As you consider the free web based learning games accessible, you need to ensure you pick a site that has what your kid needs. </s><s> This
  you hated this year as the best in their field. </s><s> The Redbox Movie Awards 2011: for when even the People's Choice Awards are considered 'too highbrow'. </s><s> A wonderfully intimate project. </s><s> A warm and wonderfully universal love story that comes across
), when weighing increased bleeding risk against reduced thrombosis issues. </s><s> However, Dr Patel said he preferred to consider the mortality rate as the key benefit: There are only a handful of interventions in cardiovascular medicine that can
the course of your mortgage. </s><s> Jumbo loan: Any loan above the conventional loan limits set by Fannie Mae and Freddie Mac is considered a jumbo loan. </s><s> Current limits are $548,250 to $822,375, depending on where the property is located. </s><s> You can finance up to
gap in the Pew study concerned genetically modified foods, which 88% of scientists but only 37% of the general public consider safe to eat. </s><s> Another big gap: 68% of scientists versus 28% of the general public think foods grown with pesticides are
whole grain symbol, which tells you how many grams of whole grain each serving contains. </s><s> Sixteen grams per serving is considered an excellent source and 8 grams is a good source. </s><s> If there is no symbol, read the label, and pick foods listing whole
sometimes been criticized because we do not emphasize a follow-up program for students. </s><s> Jesus and the apostles did not consider follow-up vital to successful evangelism. </s><s> Instead, Jesus expected true disciples to follow Him. </s><s> When He witnessed to
terms of their effects upon an individual at first encounter and without the influence of pain. </s><s> The latter influence is considered insignificant in the case of the surface temperature measurements. </s><s> Therefore, when considering this question the
rest of my post will be just of theoretical nature. </s><s> I want to compare 4-wide with and without an odd clear beforehand. </s><s> I consider the 2 following builds pretty much optimal for 7-high builds (I am assuming a line was already cleared because they ca
, requires an article would include is an, because without is, there seems to have worked. </s><s> The values category was considered a form of association should encompass or exclude the jews while including or % of the house style. </s><s> Ikegami, eiko. </s><s> All
, than that there is a God), cannot all be correct, just like not all answers to 2+2=? are correct. </s><s> Well, they might have considered it a toss-up between 'pure' unbelief and self-interested hypocrisy and heresy, which certainly are not the same as
identity as an overseas collectivity is somewhat precarious: The status of the island </s><s> within the French republic is considered provisional and will be reviewed in 2010. </s><s> Ethnic Relations. </s><s> Mahorans, who have family ties to the inhabitants of the
the Sultan Omar Ali Saifuddien Mosque with its marble minarets and gold domes. </s><s> See the Water Village (Kampong Ayer), considered the Venice of the East, where more than 30,000 residents living in stilt houses. </s><s> 0 Princess Cruises will make maiden
thus can be found when considering the application of McLuhan's ideas in the context of Compendium. </s><s> McLuhan is considered a revolutionary in some quarters in considering how different technological inventions were extending the reach of
satisfaction and loyalty. </s><s> It will also guarantee the development of Zoomlion's hoisting machinery. </s><s> Zoomlion is considered the 'cradle' of China's hoisting machinery industry. </s><s> From laying the foundation of tower crane technology in China,
to hire a great web developer, like the ones employed by Ramotion. </s><s> You have to remember always that your brand should be considered as one of the top providers of great products or services. </s><s> Then, through an integrated digital marketing strategy,",
  "You have reached an accuracy of 59%",
  "Let's review the errors. I have pasted all the sentences you have got wrong",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# 3.2 UNSUPERVISED TRAINING 2

# Prompt
res <- ask_llm(conv, paste(
  "Keep those lessons in mind. I will now give you new data. In your classification, you need to <thinking> Classify step-by-step</thinking> and <instruction> consistently apply insertion test </instruction>",
  "<instructions>",
  "Return the full classification in one batch.",
  "Return ONLY tab-separated values with columns:",
  "id\tClassification",
  "Do not include explanations, code blocks, or any extra text.",
  "</instructions>",
  paste(
    apply(unsup_training_set2, 1, function(row) {
      paste0("id: ", row["id"], " | Sentence: ", row["Sentence"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# Gather feedback (only accuracy) for unsupervised training 2
# Read and save output

# Clean and save model output
tsv_unsup2 <- res$answer |>
  gsub("</?answer>", "", x = _) |>
  gsub("```", "", x = _) |>
  trimws()

# as before: keep only headers and rows that start with a number
lines <- strsplit(tsv_unsup2, "\n")[[1]]
table_lines <- lines[grep("^(id|[0-9])", lines)]
tsv_clean <- paste(table_lines, collapse = "\n")

unsup2_mistral_results <- read_tsv(I(tsv_clean))

# rename second column
names(unsup2_mistral_results)[2] <- "Mistral_classification"

#ncol(unsup2_mistral_results) # check columns

# Merge and compare accuracy
comparison_unsup2 <- unsup2_solution |>
  left_join(unsup2_mistral_results, by = "id")

accuracy_unsup2 <- mean(
  comparison_unsup2$classification_Matti == comparison_unsup2$Mistral_classification
)

print(accuracy_unsup2)

# Give feedback
res <- ask_llm(conv, paste(
  "You got a 76% accuracy, which is an improvement compared to the previous round (59%). The goal remains at least 95%. Please acknowledge this in one short line.",
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# 4. TESTING

# Testing prompt and dataset
res <- ask_llm(conv, paste(
  "Now we're proceeding from training and validation to testing. I will provide you with a new dataset. <instructions> Classify the data following the procedure that you have applied successfully in the latest round of classifications.</instructions>",
  "<instructions> Return the full classification in one batch. Return ONLY tab-separated values with columns:",
  "id\tClassification",
  "Output exactly what is asked. Do NOT include anything else — no text, no comments, no code formatting.",
  "</instructions>,",
  paste(
    apply(testing_set, 1, function(row) {
      paste0("id: ", row["id"], " | Sentence: ", row["Sentence"])
    }),
    collapse = "\n"
  ),
  sep = "\n"
), MISTRAL)
conv <- res$conversation
print(res$answer)

# EVALUATION (and final prompt)

# Clean and save model output
tsv_test <- res$answer |>
  gsub("</?answer>", "", x = _) |>
  gsub("```", "", x = _) |>
  trimws()

# Filter
lines <- strsplit(tsv_test, "\n")[[1]]
table_lines <- lines[grep("^(id|[0-9])", lines)]
tsv_clean <- paste(table_lines, collapse = "\n")

# Read and save tsv
test_mistral_results <- read_tsv(
  I(tsv_clean),
  col_names = c("id", "Mistral_classification")
) |>
  mutate(id = as.numeric(id)) |>
  filter(!is.na(id))  # remove the header row

# Compare with human gold standard annotations and compute accuracy

comparison_test <- human_gold_standard |>
  left_join(test_mistral_results, by = "id")

accuracy_test <- mean(
  comparison_test$Human_classification == comparison_test$Mistral_classification
)

print(accuracy_test)

# Save as csv.
write_csv2(comparison_test, "replication_data/Mistral_replication_results.csv") # put in semicolon separated format for comparison with author's table


# Final prompt
res <- ask_llm(conv, paste(
  "",
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