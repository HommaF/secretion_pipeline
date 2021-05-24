#!/usr/bin/env python


import sys
import pandas as pd
import numpy as np

from Bio import SeqIO
from Bio.SeqUtils.ProtParam import ProteinAnalysis

file_name = sys.argv[1]
output_name = sys.argv[2]

seqs = SeqIO.to_dict(SeqIO.parse(sys.argv[1], "fasta"))
new = []

for i in seqs:
    new.append([i, ("%.3f" % (ProteinAnalysis(str(seqs[i].seq)).molecular_weight()/1000))])

df = pd.DataFrame(new, columns=['ID', 'mol_weight[kDa]'])
df.to_csv(output_name, sep='\t', index=False)
