# Anonymized research materials

This study is based on a replication of Morin & Marttinen Larsson (2025), and the study data they have provided. It contains a close replication of Morin & Marttinen Larsson (2025) with different LLMs (Mistral Small 3.2 24B Instruct 2506 and OpenAI GPT OSS 120B), and an extended replication of this approach, using a simpler, more compact training approach with OpenAI GPT OSS 120B. This folder contains the code, data, and supporting materials required to reproduce the analyses reported in the accompanying manuscript.

## DATA & FILE OVERVIEW

// File List:

Basis:

- 0_peer_review.Rproj (project file)

- 0_Insights_from_replications.qmd (manuscript)

- 0_Insights_from_replications.pdf (manuscript in pdf format)

- 0_Appendix (appendix to manuscript)

Essential R scripts for all parts of replication:

- 1_Data_import.R (importing and preprocessing of data)

- 1_LLM_setup.R (Setup script for LLMs)

- /data (folder containing all data provided by Morin & Marttinen Larsson 2025, including 'conversation' transcript)

Replications:

- 2_Mistral_replication.R (script used for replication with Mistral model)

- 3_GPT_replication.R (script used for replication with GPT, both closed and extended)

- /replication_data (folder containing results of close replication)

  - /replication_data/comparison_all_results.csv (csv file comparing all relevant annotations: from the model used in the original study, the human gold standard annoatations from the original study, and both models tested in this replication

  - /replication_data/GPT_replication_results.csv (csv containing annotations from the GPT model in close replication and the human gold standard provided in the original study)

  - /replication_data/Mistral_replication_results.csv (csv containing annotations from the Mistral model in close replication and the human gold standard provided in the original study)

- /transcripts (folder containing 'conversation' transcripts from close replications)

- /reduced_training (folder containing results of extended replication with reduced training approach with GPT)

  - /reduced_training/GPT_reduced_training_2_results.csv (csv file containing annotations from replication with reduced training and the human gold standard provided in the original study)

  - /reduced_training/GPT_20260706_RAW.txt (transcript of 'conversation' during reduced training)

1\. Folder "data": contains all data from the original study provided by the original authors \<List all files (or folders, as appropriate for dataset organization) contained in the dataset. Where appropriate, a file overview may be provided by explaining file naming conventions, instead of listing individual files. For each file (or folder), provide a brief description of what data it contains, and of the file format (e.g. plain text) if not obvious from file extension (e.g. .txt). If necessary, also include system and hardware requirements needed to open and read the file.\>

// Relationship between files:

The "data" folder contains all data that was provided by Morin & Marttinen Larsson (2025) and that was used for replication. The other folders "replication_data", "transcripts", and "reduced_training" all contain results that were produced during the replications. The other files are numbered: Files starting with 0 contain the basic components necessary to understand and reproduce the study. Files starting with 1 are part of the setup necessary to later train and test the LLMs. The code for the actual training, testing and evaluation of the models is located in files numbered 2 and 3.

