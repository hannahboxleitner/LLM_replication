# Replication study: Morin & Larsson (2025): "Large corpora and large language models: a replicable method for automating grammatical annotation"
# January 2026


# load necessary libraries

library(httr)
library(jsonlite)

# building request (including content, model etc.)

payload <- '{
  "messages":[
    {
      "role":"user",
      "content":"is Tokyo or Istanbul the bigger city"
    },
    {
      "role": "user",
      "content": "I think the moon is bigger than the earth. Is that true?"
    }
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

call_llm <- function(question) {
  payload <- sprintf('{
    "messages":[
      {
        "role":"user",
        "content":"%s"
      }
    ],
    "model":"Mistral Small 3-2-24b Instruct KI:Inferenz.nrw"
  }', question)
  
  response <- VERB(
    "POST", 
    "https://chat.kiconnect.nrw/api/v1/chat/completions", 
    body = payload, 
    add_headers('Authorization' = 'Bearer 696737b2064cdc09cc517014:cZF+T2q6DsUFHgolXB56Hn0sUG+eT46viIQEDRaISk4='), 
    content_type("application/json"), 
    encode = "json"
  )
  return(content(response, "parsed"))
}

call_llm("Tell me a five-word story")

