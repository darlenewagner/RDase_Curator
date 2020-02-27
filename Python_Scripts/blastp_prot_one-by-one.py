#!/usr/bin/python

import sys
import os.path
import argparse
import re
import logging
import warnings
import csv
import xml.etree.ElementTree as ET
import subprocess

## blastp_prot_one-by-one.py takes a fasta-formatted protein file (.faa) and iterates 
## through each sequence to compare it through blastp against a blast database (.pin)
## blastp output (--blastout) may be simple tabular or extraction of annotation from xml
#### Dependencies: ncbi-blast-2.2.26+ or higher and Python3.4 or higher 

## Function: A closure for .tsv or .csv extension checking
def tsv_check(expected_ext1, expected_ext2, openner):
    def extension(filename):
        if not (filename.lower().endswith(expected_ext1) or filename.lower().endswith(expected_ext2)):
            raise ValueError()
        return openner(filename)
    return extension

## Function: check that --identity is between 0 and 100, inclusive
def bandwidth_type(x):
    xx = int(x)
    if( xx < 0 ):
        raise argparse.ArgumentTypeError("Minimum --identity cannot be negative")
    elif( xx > 100 ):
        raise argparse.ArgumentTypeError("Maximum --identity cannot be > 100")
    return xx

logger = logging.getLogger("blastp_prot_one-by-one.py")
logger.setLevel(logging.INFO)

parser = argparse.ArgumentParser(description='', usage="blastp_prot_one-by-one.py --blastout (brief|xml) NCBI_proteome.faa blastp_formatted_db")

parser.add_argument("proteome", type=tsv_check('.txt', '.faa', argparse.FileType('r')))

parser.add_argument('db')

parser.add_argument("--blastout", '-b', default='brief', choices=['brief', 'b', 'xml'], help="brief for tabbed blast output, otherwise xml for viewing annotation")
parser.add_argument("--identity", '-i', type=bandwidth_type, default=25)

args = parser.parse_args()

filehandle = open(args.proteome.name, 'r')

dbhandle = open(args.db, 'r')

position = 0

fastaDict = {}

keyList = []

appendSeq = ""
prevLine = []
seeLine = ""

## Populate dictionary of two-element lists from proteome file
for line in filehandle:
    if(re.search('^>', line)):
        if(position == 0):
            prevLine = line.split(' ', 1)
        else:
            fastaDict[prevLine[0]] = [prevLine[1].strip() ,appendSeq] # use accession as key with annotation and sequence as elements
            appendSeq = ""
            prevLine = line.split(' ', 1)
        position = position + 1
    elif(re.search('^[A-Y]', line)):
        appendSeq = appendSeq + line.rstrip()

fastaDict[prevLine[0]] = [prevLine[1].strip(), appendSeq]

#print(seeLine + " -> " + appendSeq)
#print(len(fastaDict))
#print(fastaDict[prevLine[0]])
database = dbhandle.name[:-4]

#print(database)

blastHit = ""

for key in sorted(fastaDict.keys()):
    query = key + "\n" + fastaDict[key][1] + "\n"
    fh = open('query.faa', 'w')
    fh.write(query)
    fh.close()
    open('query.faa', 'r')
    if(args.blastout == 'xml'): ## Return top five blastp hits, --identity user threshold not used
        blastHit = os.popen("blastp -db {} -query {} -outfmt 5 -max_target_seqs 5 -evalue 0.1".format(database, fh.name)).read()
        xmlTree = ET.fromstring(blastHit)  ## Constructor for xml.etree.ElementTree
        #print(xmlTree.tag, xmlTree.attrib) # info for root of xmlTree
        #for child in xmlTree:
        #    print(child.tag)
        print(xmlTree[5].text + "\t", end="") ## display <BlastOutput_query-def>
        for hits in xmlTree[8][0][4]:         ## iterate through elements of <Iteration_hits>
            print(hits.find('Hit_def').text + "\t", end="")
            evalues = 0
            for stats in hits.find('Hit_hsps'):  ## iterate through elements of <Hit_hsps>
                if(evalues == 0):
                    print(stats.find('Hsp_evalue').text + "\t", end="")
                evalues = evalues + 1
        print()
    else:  ## Return single top blasp hit only
        blastHit = os.popen("blastp -db {} -query {} -outfmt 6 -max_target_seqs 1 -evalue 0.05".format(database, fh.name)).read()
        if(blastHit == ""):
            print(key + " " + fastaDict[key][0])  ## Return query seq ID and its annotation
        else:
            outputLine = blastHit.split('\t')
            if(float(outputLine[2]) < args.identity): ## If blastp hit identity < user threshold
                print(key + " " + fastaDict[key][0])  ## Return query seq ID and its annotation
            else:
                print(outputLine[0] + "\t" + outputLine[1] + "\t" + outputLine[2] + "\t" + outputLine[10])
    fh.close()
    
print()
