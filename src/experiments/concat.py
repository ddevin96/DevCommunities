# open csv file

import pandas as pd
files = ['/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre1.csv', 
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre2.csv',
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre3.csv',
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre4.csv',
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre5.csv',
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre6.csv',
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre7.csv',
         '/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/trimestre8.csv',]
df = pd.DataFrame()
for file in files:
    data = pd.read_csv(file)
    df = pd.concat([df, data], axis=0)
df.to_csv('/Users/ddevin/Documents/vscode/DevCommunities/data/stackoverflow/raw_data/dueanni.csv', index=False)
