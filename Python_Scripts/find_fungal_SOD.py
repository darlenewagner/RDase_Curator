#!/usr/bin/python

import sys
import os.path
import argparse
import re
import logging
import warnings
import csv
import subprocess

## finds superoxide dismutase motifs,
## Based upon consensus of Candida spp. yeast proteomes
## example:

## Function: A closure for .tsv or .csv extension checking

def tsv_check(expected_ext1, expected_ext2, openner):
    def extension(filename):
        if not (filename.lower().endswith(expected_ext1) or filename.lower().endswith(expected_ext2)):
            raise ValueError()
        return openner(filename)
    return extension


logger = logging.getLogger("find_fungal_SOD.py")
logger.setLevel(logging.INFO)

parser = argparse.ArgumentParser(description='Find proteins with superoxide dismutase motif', usage="find_fungal_SOD.py NCBI_proteome.cleanline.faa > output.faa.txt")

parser.add_argument("fasta", type=tsv_check('.txt', '.faa', argparse.FileType('r')))

args = parser.parse_args()

filehandle = open(args.fasta.name, 'r')

position = 0
header = ""

### Superoxide dismutase motif
CuOnlySOD = '(H.H.{6,10}C.....H.{15,25}D.{34,47}H)'

for line in filehandle:
    if(re.search('^>', line)):
        header = line
    elif(re.search(CuOnlySOD, line)):
        motif = re.findall(CuOnlySOD, line)
        print(header + line)
        print(motif)
    position = position + 1

print("\n")
