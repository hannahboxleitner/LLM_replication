# LLMs for corpus annotation: Close and extended replications of Morin & Marttinen Larsson (2025) using smaller open LLMs and BERT
## Project overview
This study is a replication of Morin & Marttinen Larsson (2025). The first part of this project is a close replication of Morin & Marttinen Larsson (2025) with different LLMs (Mistral Small 3.2 24B Instruct 2506 and OpenAI GPT OSS 120B. The second part consists of an extended replication of this approach: Using the same data, a simpler, more compact training approach was tested with OpenAI GPT OSS 120B, and also with a distilBERT model.

## Materials
The supplementary materials in this repository contain the following files:

Basis:
- 0_LLM_replication.Rproj (project file)
- 0_Insights_from_replications.qmd (paper)
- 0_Appendix (appendix to paper)

Essential files for all parts of replication:
- 1_Data_import.R (importing and preprocessing of data)
- 1_LLM_setup.R (Setup script for LLMs)
- /data (folder containing all data provided by Morin & Marttinen Larsson 2025, including 'conversation' transcript)

Close replication:
- 2_Mistral_replication.R (script used for replication with Mistral model)
- 3_GPT_replication.R (script used for replication with GPT, both closed and extended)
- /replication_data (folder containing results of close replication)
- /transcripts (folder containing 'conversation' transcripts)

Extended replication with GPT:
- 3_GPT_replication.R (script)
- /reduced_training (folder containing results of replication with reduced training with GPT)
- /reduced_training/GPT_reduced_training_2_results.csv (csv file containing results from replication with only pretraining dataset + testing)

Extended replication with distilBERT:
- 4_BERT_setup.R (script for one-time setup)
- 5_BERT_working_script.R (script for BERT analysis using only pretraining dataset + testing)
- /BERT_transcripts (folder containing results of first run with distilBERT)
- 6_BERT_extended.script.R (script for BERT analysis with more training data (pretraining + unsupervised training set)
- /BERT_extended_transcripts (folder containing results of BERT run with more training data)
