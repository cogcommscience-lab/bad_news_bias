# How to Make Economic News Headlines

- Take the anew dictionary `english_shortened.csv` and filter* to make four cells
	- Negative Valence Low Arousal (NLA)
		- Filter ANEW Valence < 4, arousal < 4
		- 581 word list
	- Negative Valence High Arousal (NHA)
		- Filter ANEW Valence < 4, arousal > 5
		- 1017 word list
	- Positve Valence Low Arousal (PLA)
		- Filter ANEW Valence > 5.5, arousal < 3.5
		- 1272 word list
	- Positive Valence High Arousal (PHA)
		- Filter ANEW Valence > 5.5, arousal > 5.5
		- 454 word list
- Generate Headlines:
	- Make a new ChatGPT session
	- PROMPT: I have a list of words: `paste list directly from list`
	- PROMPT: I want you to make 50 economic news headlines. The headlines must include multiple words from that long list of words
	- Repeate second prompt until 300 headlines are created that do not include Covid/Pandemic/Biden/Trump. USE THIS PROMPT:
	- PROMPT: I want you to make 50 more economic news headlines. The headlines must include multiple words from that long list of words
- Headline output:
	- See `chatgpt_headlines.csv` 
	- Order in which ChatGPT created headlines (using ANEW wordlists) are scored:
 		- First 300 are NLA
		- Second 300 are NHA
		- Third 300 are PLA
		- Fourth 300 are PHA
- Score using ANEW (see below)
	- From output, select headlines for each cell based on score, and face validity. Lightly edit for clarity.
	- See `headlines.csv`

*NB: Filtering thresholds are somewhat arbitrary, with the main goal of creating suitably long lists. Applying a similar thresholding logic resulted in lists of vastly different lengths. The main goal is to create a lists of words for headline generation, and then score those headlines using automated and human self-report approaches (which will give us some insight into the validity of the headline manipulations).

# How to Score Headlines

## Scoring using ANEW
### Dependencies
Stanford Core NLP: https://stanfordnlp.github.io/CoreNLP/

- Download, unzip, and place in a directory you will remember (e.g., home directory)

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

### Get The ANEW Code Working
In `anew_sentiment_analysis.py`, update the nlp path to reflect where you stored the Stanford Core NLP Directory

In `anew_sentiment_analysis.py`, update the anew path to reflect where you stored the ANEW dictionary

Important:

- News headlines should be a `.txt` or `.csv` file where each row encodes one headline
- The code works at the sentence level, and sentences are determined by a "." "!" "?"
- So, if a headline includes two sentences split by a "." "!" or "?", each sentence will get its own score
- Alternatively, headlines will be grouped together into one long sentence until a "." is found.
- Therefore, be careful to make sure each headline has only one ".", "?", or "!" mark  at the very end of the headline and nowhere else.
- Remeber to use the raw `headlines.csv` file for empirical testing; it includes punctuation

### Run the ANEW code
	$ python anew_sentiment_analysis.py --dir /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/ --file /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/headlines.csv --out /home/rwhuskey/github_repos/bad_news_bias/headline_scoring/ --mode mean

This will take a moment to run. This code is not efficient.

## Scoring Using Lexicoder
### Dependencies

Lexicoder scording code

- `lexicoder_sentiment_analysis.R`

- `restructure.py`

Lexicoder preprocessing script

- `LSDprep_dec2017.R`

Raw data

- `headlines.csv`

### Run the Lexicoder Code
See comments in `lexicoder_sentiment_analysis.R`

Note... step3 requires an ugly hack: export csv, restructure w/ `restructure.py`, load back to R

Before running `restructure.py` notice the first and last headline in your output file `headlines_preproc.csv`. You will need to update lines 10 and 11 in `restructure.py` with those headlines. Also, be sure to update the output path (line14).

## Scoring Flesch Reading Ease and Word Count

In an interactive python environment (e.g., jupyter notebook), run the `reading_ease.ipynb` code

### Dependencies

textstat

- https://pypi.org/project/textstat/

- Install using e.g., from a terminal using

	`$ pip install textstat`

## Checking Convergent Validity

Convergent validity code

- `convergent_validity.R`

Convergent validity data

- `headlines_convergent_validity.csv`

This code looks at the relationship between automated text features. Summary statistics:

- ANEW Valence Scores:
	- 109 headlines < scale midpoint of 5
	- 99 headlines > scale midpoint of 5
- ANEW Arousal Scores:
	- 112 headlines < scale midpoint of 5
	- 96 headlines > scale midpoint of 5
- ANEW valence and lexicoder net tone are highly correlated (r = .86). This is good evidence of convergent validity between the two measures of valence.
- ANEW Valence and ANEW arousal are not correlated (r = -.15, n.s. with a corrected p < .01 criterion). This is what we want, since our manipulation treats arousal and valence as orthogonal.
- ANEW Valence and ANEW arousal are not correlated with word count. This is great, it suggests that number of words is not driving the score.
- ANEW arousal is slightly correlated with flesch score (r = -.24). This is not perfect because it suggests that increased word complexity is associated with decreased headline arousal. But it is tolerable since the bag-of-words ANEW disctionary is noisy on short texts, as is the Flesch score. 
- Flesch score and word count are correlated (you'd expect this, given how each is calculated, this should be OK)
- Average ANEW valence is slightly higher (M = 4.99) than average ANEW arousal (M = 4.62; t(367) = 4.53, p < .001)
- THESE ARE ALL OBSERVATIONS ON THE CHATGPT GENERATED HEADLINES THAT WERE SCORED USING AUTOMATED ROUTINES. ADDITIONAL STATISTICS EXIST FOR THE HUMAN ANNOTATIONS, AND THESE ANNOTATIONS GUIDE OUR MANIPULATION.

## Scoring With Human Annotators
These headlines were manually inspected and an initial subsample were selected for further evaluation.
