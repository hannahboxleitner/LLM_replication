# Data import
# Data from repository by Morin & Marttinen Larsson (2025)

# This script contains all data imports and data preprocessing necessary for the replication study.


# Load libraries
library(here)
library(tidyverse)

# Load the pretraining data
pretraining_set <- read_csv2(here("data", "Pretraining_data_493.csv"))

# Load data for supervised training
sup_training_set <- read_csv2(here("data", "Supervised_training_sketchengine_100.csv"))

# Load data for unsupervised training (1)
unsup_training_set1 <- read_csv2(here("data", "Test1_sketchengine_100.csv"))

# Load solution data for feedback in unsupervised training (1)
unsup1_solution <- read_csv2(
  here("data", "Test1_sketchengine_100_solution.csv")
) |>
  select(
    id,
    Sentence,
    Classification_Matti
  )

# Load data for unsupervised training (2) and rename column for consistency
unsup_training_set2 <- read_csv2(
  here("data", "EnTenTen_random_sample_101.csv")
) |>
  select(id, Consider_construction) |>
  rename(Sentence = Consider_construction)

summary(unsup_training_set2) # check if renaming worked

# Load data for feedback in unsupervised training (2)
unsup2_solution <- read_csv2(
  here("data", "EnTenTen_random_sample_101.csv")
) |>
  select(
    id,
    Sentence = Consider_construction,
    classification_Matti
  )

# Load data for testing
testing_set <- read_csv2(here("data", "EnTenTen_random_sample_102.csv")) |>
  select(id, Consider_construction) |>
  rename(Sentence = Consider_construction)

summary(testing_set) # check

# Load human gold standard annotations (for testing set)
human_gold_standard <- read_csv2(
  here("data", "EnTenTen_random_sample_102.csv")
) |>
  select(
    id,
    Sentence = Consider_construction,
    Human_classification = Matti_classification
  )

# EVALUATION
# Inter-rater-agreement

# Load original study's test results for comparisons
test_original_study <- read_csv2(
  here("data", "EnTenTen_random_sample_102.csv")
) |> 
  select(
    id,
    Sentence = Consider_construction,
    Claude_classification,
    Human_classification = Matti_classification,
    
  )

# Create csv with all raters for Fleiss' κ
# Get GPT results
test_gpt <- read_csv2(
  here("replication_data", "GPT_replication_results.csv")
) |> 
  select(
    id,
    GPT_classification
  )

# Get Mistral results
test_mistral <- read_csv2(
  here("replication_data", "Mistral_replication_results.csv")
) |> 
  select(
    id,
    Mistral_classification
  )

# merge with original study's results
comparison_all <- test_original_study |> 
  left_join(test_gpt, by = "id") |> 
  left_join(test_mistral, by = "id")

# Save as csv.
write_csv2(comparison_all, "replication_data/comparison_all_results.csv")
