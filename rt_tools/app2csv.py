from email.quoprimime import quote
import sys
import os.path
from os import path
import csv

# Exports a graph to a png file. By design, dot generates
# plot layout (requires graphviz)
def app2csv(infile, outfile):
  if not path.exists(infile):
    print("unable to read input file")
    exit(0)

  with open(infile) as csvfile:
    rows = csv.reader(csvfile, delimiter=' ', quotechar='|')
    for row in rows:
      print(row)