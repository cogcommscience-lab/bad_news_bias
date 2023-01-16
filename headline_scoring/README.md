# How To Score Headlines

## Scoring using ANEW
### Dependencies
Stanford Core NLP: https://stanfordnlp.github.io/CoreNLP/

- Download, unzip, and place in home directory

- Also install using python, e.g., from a terminal using

	`$ pip install stanfordnlp`

NLTK: https://www.nltk.org/

- Install using e.g., from a terminal using

	`$ pip install --user -U nltk`

After installing, open Python in a terminal and install stopwords and punkt wordnet

	$ python

	>>> import nltk

	>>> nltk.download('stopwords')

	>>> nltk.download('punkt')

	>>> nltk.download('wordnet')

	>>> quit()

ANEW Dictionary

- See english_shortened.csv

ANEW Scoring Code

- `anew_sentiment_analysis.py`

- Borrowed from: https://github.com/dwzhou/SentimentAnalysis

News Headlines

- See `economic_news_arrticles_usa_2021_headlines_only.txt`

### Get The ANEW Code Working
In `anew_sentiment_analysis.py`, update the nlp path to reflect where you stored the Stanford Core NLP Directory

In `anew_sentiment_analysis.py`, update the anew path to reflect where you stored the ANEW dictionary

Important:

- News headlines should be a `.txt` file where each row encodes one headline
- The code works at the sentence level, and sentences are determined by a "." "!" "?"
- So, if a headline includes two sentences split by a "." "!" or "?", each sentence will get its own score
- Alternatively, headlines will be grouped together into one long sentence until a "." is found.
- Therefore, be careful to make sure each headline has only one "." at the very end of the headline and no other punctuation.
- Delete all other instances of "?" and "!"
- Remeber to use the raw `economic_news_arrticles_usa_2021_headlines.csv` file for empirical testing; it includes punctuation

### Run the ANEW code
	$ python anew_sentiment_analysis.py --dir /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/ --file /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/economic_news_arrticles_usa_2021_headlines_only.txt --out /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/ --mode mean

This will take... a while

## Scoring Using Lexicoder
### Dependencies

Lexicoder scording code

- `lexicoder_sentiment_analysis.R`

- `restructure.py`

Lexicoder preprocessing script

- `LSDprep_dec2017.R`

Raw data

- `economic_news_arrticles_usa_2021_headlines_only_with_head.csv`

### Run the Lexicoder Code
See comments in `lexicoder_sentiment_analysis.R`

Note... step3 requires an ugly hack: export csv, restructure w/ restructure.py, load back to R

## Scoring Flesch Reading Ease and Word Count

In an interactive python environment (e.g., jupyter notebook), run the `reading_ease.ipynb` code

### Dependencies

textstat

- https://pypi.org/project/textstat/

- Install using e.g., from a terminal using

	`$ pip install textstat`
