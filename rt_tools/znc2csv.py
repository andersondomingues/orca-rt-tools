import sys
import os.path
from os import path

#
def formatLine(line):
  charBuffer = []
  items = []

  for c in line:
    if(c == ' ' or c == '\t' or c == '\n'):
      if len(charBuffer) > 0:
        item = int(''.join(charBuffer))
        items.append(item)
        charBuffer = []
    else:
      charBuffer.append(c)

  return items

def znc2csv (infile, outfile):

  firstLine = True
  rows = []

  with open(infile) as f:

    for line in f:
      if firstLine:
        rows = formatLine(line)
        firstLine = False
      else:
        column = formatLine(line)
        for i in range(0, len(column)):
          if column[i] != -1:
            if rows[i] == -1 or rows[i] > column[i]:
              rows[i] = column[i]
    
    for r in rows:
      print(r, end=',')

  # print(rows[0])
  return 1