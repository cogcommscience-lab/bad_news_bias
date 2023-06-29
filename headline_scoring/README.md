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
	- Repeate second prompt until 300 headlines are created that do not include Covid/Pandemic/Biden/Trump. 
	- If you need to make a few more headlines after deleting based on the above criteria, USE THIS PROMPT:
	- PROMPT: I want you to make 50 more economic news headlines. The headlines must include multiple words from that long list of words
- Headline output:
	- See `chatgpt_headlines.csv` 
	- Order in which ChatGPT created headlines (using ANEW wordlists) are scored:
 		- First 300 are NLA
		- Second 300 are NHA
		- Third 300 are PLA
		- Fourth 300 are PHA
- Score using ANEW (see below)
	- Scoring via ANEW yields `headlines_anew.csv`
	- From `headlines_anew.csv`, select headlines for each cell based on score, and face validity. Lightly edit for clarity.
	- See selected and lightly edited headlines in `headlines.csv`

*NB: Filtering thresholds are somewhat arbitrary, with the main goal of creating suitably long lists. Applying identical thresholding logic to all four cells resulted in lists of vastly different lengths. The main goal is to create a lists of words for headline generation, and then score those headlines using automated and human self-report approaches (which will give us some insight into the validity of the headline manipulations).

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

- See `english_shortened.csv`

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
Update paths as needed.

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
- These are observations on ChatGPT generated headlines that were subsequently scored using a dictionary-based approach. The main goal was to select headlines for subsequent human annotation and cross validation (below)

## Scoring With Human Annotators
The headlines in `headlines_convergent_validity.csv` were then evaluated using human annotators on Prolific Academic (n=305). The survey files are in the `qualtrics` directory.  Each headline received an average of 29.3 ratings (range = 25 - 32). Headlines were scored on arousal/valence/dominance using the SAM. Headlines were also scored on comprehension, liking, familiarity, and seen before (see `prolific_merged_data.xlsx`).

A cross-validation analysis* was then conducted (`circumplex_plot.R`) to examine the relationship between dictionary (Anew/Lexicoder) and human annotations (MTurk using SAM). Relationships between variables of no interest were also examined. The code selects (`testing_headlines.csv`) the top highest/lowest scoringheadlines (14 per cell, 56 total) based on human annotation (for results see circumplex plot below). The correlation between human and dictionary annotation was high. In instance of disagreement, human annotators "won". Summary statistics (correlation matrix was Bonferroni corrected for multiple comparisons, p < .00059):

- Good News:
	- SAM valence (V_Mean) is uncorrelated with self-reported arousal (A_Mean) and dominance (D_Mean)
	- SAM valence is correlated with ANEW valence (r = .85) and netlexitone (r = .81)
	- SAM arousal (A_Mean) is correlated with ANEW arousal (r = .41)
	- Flesch score is uncorrelated with SAM valence, SAM arousal, SAM dominance, comprehension (C_Mean), familiarity (F_Mean), seen before (S_Mean)
	- Wordcount is uncorrelated with SAM valence, SAM arousal, SAM dominance, comprehension, familiarity, seen before
- Items to note:
	- SAM valence is strongly correlated with liking (r = .87). Our DDM hypothesis is opposite, so this works against us.
	- SAM arousal is correlated with comprehension (r = .39), familiarity (r = .41) and seen before (r = .27). Not perfect, but these are ChatGPT generated headlines.
	- As is commonly observed elsewhere in the literature, SAM dominance is correlated with SAM arousal (r = .83)

A series of ANOVA models were also fit to examine the cells in aggregate by valence and arousal:
- sam_valence ~ sam_cells(nla, nha, pla, pha)
	- F(3, 52) = 708, p < .001
	- All pairwise comparisons are significantly different, after Bonferroni correction, p < .001
	- Ideally, cells would be invariant within valence level (i.e., nla vs. nha = n.s., pla vs. pha = n.s.). Still, this is tolerable
- sam_arousal ~ sam_cells(nla, nha, pla, pha)
	- F(3, 52) = 180.2, p < .001
	- All pairwise comparisons are significantly different, after bonferroni correction, p < .001
	- Similar concerns to the SAM valence model

The FINAL headlines used for DDM testing are in `testing_headlines.csv`.

*Note, all these analyses are on averaged human annotation data and each human annotator rated multiple headlines (there is some dependency in the data). Still, this evidence all indicates that we have headlines that systematically vary on arousal and valence and are largely uncorrelated with other factors that might influence the DDM result (e.g., word count, reading ease).

Circumplex plot showing ANEW labels (color) and SAM ratings (point estimates and uncertainty). Results show good (but not perfect) agreement between ANEW and SAM.
![Circumplex plot for 56 news headlines based on ANEW ratings](https://github.com/cogcommscience-lab/bad_news_bias/blob/main/headline_scoring/anew_sam_circumplex.png?raw=true)

Circumplex plot showing SAM labels (color) and SAM ratings (point estimates and uncertainty). Results show strong distinction betwee valence (high/low) and slightly weaker distinction between arousal (high/low). All cell levels are above/below the scale mean.
![Circumplex plot for 56 news headlines based on SAM ratings](https://github.com/cogcommscience-lab/bad_news_bias/blob/main/headline_scoring/sam_sam_circumplex.png?raw=true)

Correlation matrix showing significant relationships between variables. N.S. correlations are not shown.
![Correlation matrix showing relationships between variables](https://github.com/cogcommscience-lab/bad_news_bias/blob/main/headline_scoring/cormatrix.png?raw=true)
