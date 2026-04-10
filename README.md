# Using (open) LLMs for linguistic annotation tasks: Replication of a study by Morin & Marttinen Larsson (2025)
## Project overview
This repository contains the following materials for a replication study:

1. Data
   - Folder "data": contains all the datasets from the original study, which were downloaded from the OSF repository corresponding to Morin & Marttinen Larsson (2025). The file names remain unchanged.
   - Folder "replication_data": contains datasets derived from the replication.
   - Folder "transcripts": contains transcripts of the conversations conducted with LLMs for replication.
3. R files
   - "Data_import.R": R script containing all data imports
   - "LLM_setup.R": R script containing the basic setup of LLMs via remote API.
   - "GPT_replication.R": R script containing the replication with the GPT model.
   - "Mistral_replication.R": R script containing the replication with the Mistral model.
   - "LLM_replication_paper.qmd": contains a Quarto document containg the actual paper (also as .html file)
5. Other
   - "references.bib": bibliographic entries.
