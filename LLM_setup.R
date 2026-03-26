# LLM Setup

# This script contains everything necessary to set up the LLMs for usage in multi-turn conversations.
# To avoid repetition and unnecessarily long scripts, it will be called in both the pilot study ("LLM_pilot.R") and the actual replications ("GPT_replication.R" and "Mistral_replication.R")
# The API key is saved as an environment variable in a .renviron file outside of the project folder and called inside of the function.


# Load libraries
library(httr)
library(jsonlite)
library(tidyverse) # for dplyr and readr

MISTRAL = "Mistral Small 3-2-24b Instruct KI:Inferenz.nrw"
GPT = "OpenAI GPT OSS 120b KI:Inferenz.nrw"


# Assign conv function for conversation as a list of messages
create_conversation <- function() {
  list(messages = list())
}

# Function for adding message to conv object (with role and content)
add_message <- function(conv, role, content) {
  conv$messages <- append(conv$messages, list(list(
    role = role,
    content = content
  )))
  conv # return the updated conversation
}

# API call function: sends conversation to API and returns answer
call_llm <- function(conv, api_key, model) {
  
  payload <- list(
    model = model,
    messages = conv$messages,
    seed = 712,
    temperature = 0,
    top_p = 1.0
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

# Function for user-question (adds user question to the conversation and sends to API)
ask_llm <- function(conv, question, model) {
  
  api_key <- Sys.getenv("MISTRAL_API_KEY")
  
  conv <- add_message(conv, "user", question)
  
  res <- call_llm(conv, api_key, model)
  
  cat(
    "\n\n----------------------------\n",
    "USER:\n", question,
    "\n\nMODEL:\n", res$answer,
    file = log_file,
    append = TRUE
  ) # for logging raw transcript
  
  res
}


conv <- create_conversation() # conv-object: resets conversation every time I run it


# File naming for transcript

model_name <- "GPT" # change

run_id <- paste0(
  model_name, "_",
  format(Sys.Date(), "%Y%m%d")
)

dir.create("transcripts", showWarnings = FALSE)

log_file <- paste0("transcripts/", run_id, "_RAW.txt") # for checking model output during conversation/analysis
clean_file <- paste0("transcripts/", run_id, "_CLEAN.txt") # for whole transcript


# Testing multi-turn conversation
#res <- ask_llm(conv, "Name one subfield of linguistics.", GPT)
#conv <- res$conversation
#print(res$answer)

#res <- ask_llm(conv, "What is the most interesting aspect of this subfield? Answer in one sentence.", GPT)
#conv <- res$conversation
#print(res$answer)
