# test tidyllm

#install.packages("tidyllm")
library(tidyllm)

# set up API key
Sys.setenv(OPENAI_API_KEY = "696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4=")

my_provider <- openai(.model="Mistral Small 3-2-24b Instruct KI:Inferenz.nrw",
                      .api_url="https://chat.kiconnect.nrw",
                      .compatible = TRUE,
                      .api_path = "/api/v1/chat/completions",
                      .api_key = "696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4="
)

llm_message("Hi there") |>
  chat(my_provider)

# try to set default model
options(tidyllm_chat_default = mistral(.model = "Mistral Small 3-2-24b Instruct KI:Inferenz.nrw"))

# Start a conversation
conversation <- llm_message("What is the capital of France?") |>
  chat(tidyllm_chat_default)

#Standard way that llm_messages are printed
conversation


## other try: work with lists

library(httr)
library(jsonlite)

# conversation as a list (of lists)
create_conversation <- function() {
  list(messages = list())
}

# function for adding a message
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

# function for user-question
ask_llm <- function(conv, question, api_key) {
  
  conv <- add_message(conv, "user", question)
  
  res <- call_llm(conv, api_key)
  
  res
}

# try it out

conv <- create_conversation()

res <- ask_llm(conv, "What is linguistics", api_key = "696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4=")
conv <- res$conversation
print(res$answer)

res <- ask_llm(conv, "Yes,I would like more details on Sociolinguistics.", api_key = "696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4=")
conv <- res$conversation
print(res$answer)

res <- ask_llm(conv, "Please summarize it in one sentence.", api_key = "696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4=")
conv <- res$conversation
print(res$answer)


## Additional options (maybe useful for study!)

## Defining a system prompt (for detailed instructions about classification steps?)
#conv <- create_conversation()
#conv <- add_message(conv, "system",
#                    "You are a classifier that labels sentences as positive or negative.")


## For several training rounds
#training_data <- c(
#  "I love this movie",
#  "This is terrible",
#  "The weather is great"
#)

#for(sentence in training_data) {
#  res <- ask_llm(conv, paste("Classify:", sentence), api_key)
#  conv <- res$conversation
#}


## maybe save every conversation as json log (for reproducibility purposes)
#write_json(conv$messages, "conversation_log.json", pretty = TRUE)