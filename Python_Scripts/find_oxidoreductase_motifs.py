#!/usr/bin/python

import sys
import os.path
import argparse
import re
import logging
import warnings
import csv
import subprocess

## finds amino acid sequence motifs for proteins involved in
## detoxification of reactive oxidative species and/or biosynthesis
## Based upon consensus of Candida spp. yeast proteomes
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
    motifs = ['CuOnlySOD', 'cytP450', 'FAD_binding_1', 'WrbA', 'glutared']
    if not candidate in motifs:
        raise argparse.ArgumentTypeError("{} is not a valid motif name".format(candidate))
    return candidate

logger = logging.getLogger("find_oxidoreductase_motifs.py")
logger.setLevel(logging.INFO)

parser = argparse.ArgumentParser(description='Find proteins with various oxidoredutases motifs', usage="find_oxidoreductase_motifs.py --model motifName NCBI_proteome.cleanline.faa > output.faa.txt")

parser.add_argument('--model', '-M', type=model_check, required=True, help="A valid motif/model name, e.g. cytP450")
parser.add_argument("fasta", type=tsv_check('.txt', '.faa', argparse.FileType('r')))

args = parser.parse_args()

motif = args.model
filehandle = open(args.fasta.name, 'r')

position = 0
header = ""


### Motifs for various oxidoreductases in yeasts are populated into a dict ###
# motifDictionary = {CuOnlySOD: superoxide dismutase, 
#                    cytP450: cytochrome P450 (includes ERG11),
#                    FAD_binding_1: diflavin oxidoreductase,
#                    WrbA: NADH quinone oxidoreducase,
#                    glutared: glutaredoxin/thioredoxin}

motifDictionary = {'CuOnlySOD' : '(H.H.{6,10}C.....H.{15,25}D.{34,47}H)',
                   'cytP450' : '(E..R.{63,88}(P|A|G|T)(F|Y)(G|S|A).G...C.G)',
                   'FAD_binding_1' : '(H.{11}(Y|F|W)..G.{8}N.{118,142}R(Y|F|W|E)Y(S|A))',
                   'WrbA' : '(W.......K....(F|M).{22,25}H.?G.{15,25}(G|S).{3,4}G)',
                   'glutared' : '(^.{3,50}(Y|F|S|T).{4,8}C(P|G|S).(C|G).{37,69}P(Q|R|N|I).{8,50}$)'}

for line in filehandle:
    if(re.search('^>', line)):
        header = line
    elif(re.search(motifDictionary[motif], line)):
       # motif = re.findall(, line)
        print(header + line)
       # print(motif)
    position = position + 1

print("\n")
