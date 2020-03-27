#!/usr/bin/python

import sys
import os.path
import argparse
import re
import logging
import warnings
import csv
import subprocess

## finds amino acid sequence motifs for paralogous proteins
## predicted to be involved in chitin biosynthesis
## Based upon motifs conserved across all fungi shown in 
## Liu et al. (2017) "Evolution of the chitin synthase gene family correlate
## with fungal morphogenesis and adaptation to ecological niches" Scientific Reports
## Dependency: Python/3.4 or higher

## Function: A closure for .tsv or .csv extension checking

def tsv_check(expected_ext1, expected_ext2, openner):
    def extension(filename):
        if not (filename.lower().endswith(expected_ext1) or filename.lower().endswith(expected_ext2)):
            raise ValueError()
        return openner(filename)
    return extension


# Function: Make sure user --model is a valid key for dictionary of motifs
def model_check(x):
    candidate = x
    motifs = ['signature1', 'signature2', 'productBinding', 'productCatalysis']
    if not candidate in motifs:
        raise argparse.ArgumentTypeError("{} is not a valid motif name".format(candidate))
    return candidate

logger = logging.getLogger("find_chitin_synthase_motifs.py")
logger.setLevel(logging.INFO)

parser = argparse.ArgumentParser(description='Find proteins with the fungal chitin synthase motifs', usage="find_chitin_synthase_motifs.py --model motifName NCBI_proteome.cleanline.faa > output.faa.txt")

parser.add_argument('--model', '-M', type=model_check, required=True, help="A valid motif/model name, e.g. signature1")
parser.add_argument("fasta", type=tsv_check('.fas', '.faa', argparse.FileType('r')))

args = parser.parse_args()

motif = args.model
filehandle = open(args.fasta.name, 'r')

position = 0
header = ""

motifDictionary = {'signature1' : 'Q..EY',
                   'signature2' : 'QRRRW',
                   'productBinding' : 'D.D',
                   'productCatalysis' : 'EDR.L',
                   }

for line in filehandle:
    if(re.search('^>', line)):
        header = line
    elif(re.search(motifDictionary[motif], line)):
        motif1 = re.findall(motifDictionary[motif], line)
        print(header + line)
        print(motif1)
    position = position + 1

print("\n")
