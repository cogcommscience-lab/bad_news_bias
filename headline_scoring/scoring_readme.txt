# How To Score Headlines

## Dependencies
Stanford Core NLP: https://stanfordnlp.github.io/CoreNLP/
Download, unzip, and place in home directory
Also install using python, e.g., pip install stanfordnlp

NLTK: https://www.nltk.org/
Install using e.g., PIP
After installing, opn Python in a terminal and install stopwords and punkt wordnet
	$ python
	>>> import nltk
	>>> nltk.download('stopwords')
	>>> nltk.download('punkt')
	>>> nltk.download('wordnet')
	>>> quit()

ANEW Dictionary
See english_shortened.csv uploaded to GitHub repo

ANEW Scoring Code
anew_sentiment_analysis.py
Borrowed from: https://github.com/dwzhou/SentimentAnalysis

News Headlines
see economic_news_arrticles_usa_2021_headlines_only.txt uploaded to GitHub repo

## Get The Code Working
In anew_sentiment_analysis.py, update the nlp path to reflect where you stored the Stanford Core NLP Directory
In anew_sentiment_analysis.py, update the anew path to reflect where you stored the ANEW dictionary
News headlines should be a .txt file where each row encodes one headline

## Run the code
$ python anew_sentiment_analysis.py --dir /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/ --file /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/economic_news_arrticles_usa_2021_headlines_only.txt --out /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/ --mode mean

This will take... a while
