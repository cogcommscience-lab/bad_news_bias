import pandas as pd
with open('/home/rwhuskey/github_repos/bad_news_bias/headline_scoring/economic_preproc_headlines.csv') as f:
    lines = f.readlines()

text = lines[1]

text = text.split('"" , ""')

headline_df = pd.DataFrame({"headlines": text})
headline_df.headlines.iloc[0] =  ' Covid - 19 vaccine is safe for those with food and drug allergies , allergist group says . '
headline_df.headlines.iloc[-1] = ' The Tiwa Select Founder\'s Perfect Friday to Tuesday in Mexico City .'


headline_df.to_csv("/home/rwhuskey/github_repos/bad_news_bias/headline_scoring/economic_headlines_structured.csv")
