#!/usr/bin/env python

import pandas as pd
import numpy as np
import sys

df = pd.read_csv(sys.argv[1], sep='\t', engine='python', index_col=0)
molw_mat = pd.read_csv(sys.argv[2], sep='\t', engine='python', index_col=0, skiprows=1, names=['ID', 'mol_weight_mature[kDa]'])
tmhmm = pd.read_csv(sys.argv[3] ,sep='\t', engine='python', index_col=0, names=['ID', 'tmhmm_len', 'tmhmm_expaa', 'tmhmm_first60', 'tmhmm_predhel', 'tmhmm_topol'])


new = pd.concat([df, molw_mat], axis=1)
new = pd.concat([new, tmhmm], axis=1)
        

new.to_csv(sys.argv[4], sep='\t', index=True)
