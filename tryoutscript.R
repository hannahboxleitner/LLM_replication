# test tidyllm

#install.packages("tidyllm")
#library(tidyllm)

# set up API key
#Sys.setenv(OPENAI_API_KEY = "x")

#my_provider <- openai(.model="Mistral Small 3-2-24b Instruct KI:Inferenz.nrw",
#                      .api_url="https://chat.kiconnect.nrw",
#                      .compatible = TRUE,
#                      .api_path = "/api/v1/chat/completions",
                      
#)

#llm_message("Hi there") |>
#  chat(my_provider)

# try to set default model
#options(tidyllm_chat_default = mistral(.model = "Mistral Small 3-2-24b Instruct KI:Inferenz.nrw"))

# Start a conversation
#conversation <- llm_message("What is the capital of France?") |>
#  chat(tidyllm_chat_default)

#Standard way that llm_messages are printed
#conversation


## other try: work with lists

# Load libraries necessary for the project
library(httr)
library(jsonlite)
library(readr)    # for reading CSV files
library(dplyr)    # for manipulating and summarizing data

# The API key is saved as an environment variable in a .renviron file outside of the project folder and called inside of the function

# Assign conv variable for conversation as a list of messages
create_conversation <- function() {
  list(messages = list())
}

conv <- create_conversation() # resets conversation every time I run it

# Function for adding a message
add_message <- function(conv, role, content) {
  conv$messages <- append(conv$messages, list(list(
    role = role,
    content = content
  )))
  conv
}

# API call function
call_llm <- function(conv, api_key) {
  
  payload <- list(
    model = "Mistral Small 3-2-24b Instruct KI:Inferenz.nrw",
    messages = conv$messages
  )
  
  response <- POST(
    "https://chat.kiconnect.nrw/api/v1/chat/completions",
    add_headers(Authorization = paste("Bearer", api_key)),
    content_type_json(),
    body = payload,
    encode = "json"
  )
  
  result <- content(response, as = "parsed", simplifyVector = TRUE)
  
  answer <- result$choices$message$content
  
  conv <- add_message(conv, "assistant", answer)
  
  list(
    conversation = conv,
    answer = answer
  )
}

# Function for user-question
ask_llm <- function(conv, question) {
  
  api_key <- Sys.getenv("MISTRAL_API_KEY")
  
  conv <- add_message(conv, "user", question)
  
  res <- call_llm(conv, api_key)
  
  res
}

# Testing a multi-turn conversation
res <- ask_llm(conv, "What is linguistics?")
conv <- res$conversation
print(res$answer)

res <- ask_llm(conv, "Yes,I would like more details on Sociolinguistics.")
conv <- res$conversation
print(res$answer)

res <- ask_llm(conv, "Please summarize it in one sentence.")
conv <- res$conversation
print(res$answer)

# Pilot study (sentiment analysis) with small dataset
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
))
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
))
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

# 2. TRAINING

# save as text file
#writeLines(transcript_text, "pilot_data/pilot_supervised_training_transcript.txt")







## maybe save every conversation as json log (for reproducibility purposes)
#write_json(conv$messages, "conversation_log.json", pretty = TRUE)