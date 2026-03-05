# Replication study: Morin & Larsson (2025): "Large corpora and large language models: a replicable method for automating grammatical annotation"
# January 2026


# load necessary libraries

library(httr)
library(jsonlite)

# building request (including content, model etc.) -> try to integrate response and next question

payload <- '{
  "messages":[
    {
      "role":"user",
      "content":"tell me a joke"
    },
    {
      "role":"assistant",
      "content":"Sure! Heres a classic one for you:Why dont skeletons fight each other?Because they dont have the guts!Want another? Just ask!"
    },
    {"role": "user", "content": "what have we been talking about?"}
  ],
  "model":"Mistral Small 3-2-24b Instruct KI:Inferenz.nrw"
}'

# sending request (API)

response <- VERB(
    "POST", 
    "https://chat.kiconnect.nrw/api/v1/chat/completions", 
    body = payload, 
    add_headers('Authorization' = 'Bearer 696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4='), 
    content_type("application/json"), 
    encode = "json"
)

# assign variable to print in nicer format

c <- content(response, "text")
fromJSON(c)$choices


# all in one function

call_llm <- function(question, previous_conversation) {
  questions <- rbind(previous_conversation, question)
  payload <- toJSON(
    list(
      model = "Mistral Small 3-2-24b Instruct KI:Inferenz.nrw",
      messages = questions
    ),
    auto_unbox = TRUE
  )
  
  print(payload)
  
  response <- VERB(
    "POST",
    "https://chat.kiconnect.nrw/api/v1/chat/completions", 
    body = payload, 
    add_headers('Authorization' = 'Bearer 696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4='), 
    content_type("application/json"), 
    encode = "json"
  )
  print(response)
  result <- content(response, "text", encoding = "UTF-8") # not finished: eliminating weird symbols
  # Extract only the content text
  #result$choices[[1]]$message$content
}

# integrating previous responses
first_question <- data.frame(role = "user", content = "Tell me a five-word story")
response <- call_llm(first_question, data.frame(role = c(), content = c()))
first_response <- subset(fromJSON(r)$choices$message, select = c("role", "content"))
context <- rbind(first_question, first_response)

second_question <- data.frame(role = "user", content = "what have we been talking about")
second_response <- call_llm(second_question, context)
