# LLM Setup

# This script contains everything necessary to set up the LLM for usage in multi-turn conversations.
# To avoid repetition and unnecessarily long scripts, it will be used in both the pilot study ("LLM_pilot.R") and the actual replication ("LLM_replication.R")
# The API key is saved as an environment variable in a .renviron file outside of the project folder and called inside of the function.


# Load libraries
library(httr)
library(jsonlite)
library(readr)
library(dplyr)

MISTRAL = "Mistral Small 3-2-24b Instruct KI:Inferenz.nrw"
GPT = "OpenAI GPT OSS 120B KI:Inferenz.nrw"


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
    seed = 42,
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
  writeLines(
    paste(add_message(conv, "assistant", res$answer)$messages),
    sprintf("transcripts/test_%s.txt", model)
  )
  
  res
}


conv <- create_conversation() # conv-object: resets conversation every time I run it

# Testing a multi-turn conversation
#res <- ask_llm(conv, "Name one subfield of linguistics.", GPT)
#conv <- res$conversation
#print(res$answer)

#res <- ask_llm(conv, "What is the most interesting aspect of this subfield?", GPT)
#conv <- res$conversation
#print(res$answer)
