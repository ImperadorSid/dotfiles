#!/usr/bin/env python3
import pandas as pd

def load_csv(path):
    df = pd.read_csv(path)
    return df.iloc[:, :-1].to_numpy(), df.iloc[:, -1].to_numpy()
