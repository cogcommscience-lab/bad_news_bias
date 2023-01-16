# This code analyzes news headlines using the Lexicoder dictionary (Young and Soroka 2012)
  # https://www.snsoroka.com/data-lexicoder/
  # https://doi.org/10.1080/10584609.2012.671234

# It first begins by reading in and pre-processing the news headline data
  # Preprocessing achieved by using a script provided by Emily Luxon
  # LSDprep_dec2017.R
  # Luxon, E.  2017. "R Functions for Lexicoder Sentiment Dictionary Pre-Processing."
  # Downloadable via https://www.snsoroka.com/data-lexicoder/.

# It then scores the headlines using the Lexicoder dictionary
  # https://www.snsoroka.com/data-lexicoder/

# The code follows these specific steps
  # Step 0: Load packages * and set directory for preprocessing functions
  # Step 1: Read in the data
  # Step 2: Pre-process the data using the five routines described in LSDprep_dec2017.R
  # Step 3: Score the pre-processed data
  # Step 4: Write scored headlines out as csv flie

# Dependencies
  # LSDprep_dec2017.R
  # stringr
  # quanteda



# Step 0: Load packages set directory for preprocessing functions
library(stringr)
library(quanteda)
source(file = "LSDprep_dec2017.R")



# Step 1: Road in the data  
headlines = read.csv("economic_news_arrticles_usa_2021_headlines_only.csv", stringsAsFactors=FALSE, header=FALSE)



# Step 2: Pre-process the data using the five routines described in LSDprep_dec2017.R
## For full details of what the code does, see documentation in LSDprep_dec2017.R

## Preprocessing Step 1: Replace contractions
preproc_headlines <- LSDprep_contr(headlines)
print(preproc_headlines)

## Preprocessing Step 2: Clean dictionary words
preproc_headlines <- LSDprep_dict_punct(preproc_headlines)
print(preproc_headlines)

## Preprocessing Step 3: Insert spaces around punctuation marks 
preproc_headlines <- LSDprep_punctspace(preproc_headlines)
print(preproc_headlines)

## Preprocessing Step 4: Improve negation identification
preproc_headlines <- LSDprep_negation(preproc_headlines)
print(preproc_headlines)

## Preprocessing Step 5: Clean sentence structure for better dictionary performance
preproc_headlines <- LSDprep_dict(preproc_headlines)
print(preproc_headlines)


# Step 3: Score the preprocessed data
## Structure for scoring
## Build a new corpus from the texts
## See https://quanteda.io/articles/quickstart.html
#https://rdrr.io/cran/quanteda/man/data_dictionary_LSD2015.html


## Write out cleaned headlines
write.csv(preproc_headlines,"preproc_headlines.csv", row.names = TRUE)

## Run the code to clean them in Python

## Read back in
cleaned_corp <- read.csv(paste0("headlines_structured.csv"))

# Check column header
names(cleaned_corp)

# Specify column where "texts" exist and convert df to corpus
cleaned_corp_headlines <- corpus(cleaned_corp, text_field = "headlines")

# Check your work
print(cleaned_corp_headlines)

# Check the corpus works by getting summary statistics for the first 5 texts
summary(cleaned_corp_headlines, 5)

# Score the corpus using the lexicoder dictionary
cleaned_lexicoder_scores <- dfm(cleaned_corp_headlines, dictionary = data_dictionary_LSD2015)



# Step 4: Write scored headlines out as csv flie
## Convert to dataframe and export to csv
cleaned_lexicoder_df <- convert(cleaned_lexicoder_scores, to = "data.frame")

write.csv(cleaned_lexicoder_df,"cleaned_lexicoder_scores.csv", row.names = TRUE)



