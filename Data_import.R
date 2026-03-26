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
unsup_training_set1 -> read_csv2(here("data", "Test1_sketchengine_100.csv"))

# Load solution data for feedback in unsupervised training (1)
unsup1_solution <- read_csv2(
  here("data", "Test1_sketchengine_100_solution.csv")
) |>
  select(
    Sentence,
    Classification_Matti
  )

# Load data for unsupervised training (2) and rename column for consistency
unsup_training_set2 <- read_csv2(here("data", "EnTenTen_random_sample_101.csv")) |>
  select(Consider_construction) |>
  rename(Sentence = Consider_construction)

summary(unsup_training_set2) # check if renaming worked

# Load data for feedback in unsupervised training (2)
unsup2_solution <- read_csv2(
  here("data", "EnTenTen_random_sample_101.csv")
) |>
  select(
    Sentence = Consider_construction,
    classification_Matti
  )

# Load data for testing
testing_set <- read_csv2(here("data", "EnTenTen_random_sample_102.csv")) |>
  select(Consider_construction) |>
  rename(Sentence = Consider_construction)

summary(testing_set)

# Load human gold standard annotations (for testing set)
human_gold_standard <- read_csv2(
  here("data", "EnTenTen_random_sample_102.csv")
) |>
  select(
    Sentence = Consider_construction,
    Human_classification = Matti_classification
  )