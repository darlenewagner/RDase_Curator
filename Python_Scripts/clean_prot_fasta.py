#!/usr/bin/python

import sys
import os.path
import argparse
import re
import logging
import warnings
import csv
import subprocess

## removes newline from amino acid sequence data,
## facilitates analysis of length and conserved motifs,
## example:

## Function: A closure for .tsv or .csv extension checking

def tsv_check(expected_ext1, expected_ext2, openner):
    def extension(filename):
        if not (filename.lower().endswith(expected_ext1) or filename.lower().endswith(expected_ext2)):
            raise ValueError()
        return openner(filename)
    return extension


logger = logging.getLogger("clean_prot_fasta.py")
logger.setLevel(logging.INFO)

parser = argparse.ArgumentParser(description='', usage="clean_prot_fasta.py NCBI_proteome.faa")

parser.add_argument("fasta", type=tsv_check('.txt', '.faa', argparse.FileType('r')))

args = parser.parse_args()

filehandle = open(args.fasta.name, 'r')

position = 0

for line in filehandle:
    if(re.search('^>', line)):
        if(position == 0):
            print(line, end="")
        else:
            print("\n" + line, end="")
    elif(re.search('^[A-Y]', line)):
        noNw = line.rstrip()
        print(noNw, end="")
    position = position + 1

print("\n")
