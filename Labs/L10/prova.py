import pandas as pd

pd.read_csv('./Labs/L10/aquastat.csv', header=0, index_col=0).iloc[:, :-1].to_csv('./Labs/L10/aquastat_clean.csv', index=True)