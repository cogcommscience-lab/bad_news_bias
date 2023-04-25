import pandas as pd
with open('/home/rwhuskey/github_repos/bad_news_bias/headline_scoring/headlines_preproc.csv') as f:
    lines = f.readlines()

text = lines[1]

text = text.split('"" , ""')

headline_df = pd.DataFrame({"headlines": text})
headline_df.headlines.iloc[0] =  ' Government Bailouts Leave Taxpayers Burdened with Alimony . '
headline_df.headlines.iloc[-1] = ' The rise in Interest in Intimate Lifestyle Products Incites Advancement in Reality TV . '


headline_df.to_csv("/home/rwhuskey/github_repos/bad_news_bias/headline_scoring/headlines_structured.csv")
