# Using (open) LLMs for linguistic annotation tasks: Replication of a study by Morin & Marttinen Larsson (2025)
## Project overview
The first part of this project is a close replication of Morin & Marttinen Larsson (2025) with different LLMs (Mistral Small 3.2 24B Instruct 2506 and OpenAI GPT OSS 120B. In a second part, the replication was extended to try a simpler, more compact training approach with a BERT model and again with OpenAI GPT OSS 120B. Each part is represented in a separate papers.

This repository contains the following materials:

For the original (close) replication (of Morin & Marttinen Larsson 2025)

1. Data
   - Folder "data": contains all the datasets from the original study, which were downloaded from the OSF repository corresponding to Morin & Marttinen Larsson (2025). The file names remain unchanged.
   - Folder "replication_data": contains datasets derived from the replication.
   - Folder "transcripts": contains transcripts of the conversations conducted with LLMs for replication.
3. R files, qmd files
   - "Data_import.R": R script containing all data imports
   - "LLM_setup.R": R script containing the basic setup of LLMs via remote API.
   - "GPT_replication.R": R script containing the replication with the GPT model.
   - "Mistral_replication.R": R script containing the replication with the Mistral model.
   - "LLM_replication_paper.qmd": contains a Quarto document containg the actual paper (also as .html file)
5. Other
   - "references.bib": bibliographic entries.
   - "LLM_replication.Rroj": project file

For the extended replications and the related paper:

1. Data:
   - folder "reduced_training" contains both the results of reduced training with the open GPT model (as a .csv) and a raw transcript
   - (folder "BERT_transcripts" contains the session info and console output as .txt files)
2. R files, qmd files
   - "BERT_setup.R" contains setup for BERT use
   - "BERT_working_script.R" contains script used for BERT training
   - "Insights_from_replications.qmd" contains a Quarto document with abstract and paper
