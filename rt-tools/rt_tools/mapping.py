import networkx as nx
import sys
import os.path
from os import path
import pygraphviz

# return an object edge from the graph with given soruce and target nodes
def parseMap(sourceFile):
    
  if not path.exists(sourceFile):
    print("unable to read mapping file")
    exit(0)

  with open(sourceFile) as f:
    lines = f.read().splitlines() 

  split = []

  for line in lines:
    split.append(line.split(':'))

  fixsplit = []

  for s in split:
    fixsplit.append({"node" : s[0], "tasks" : s[1].split(',')})

  print(fixsplit)

  return fixsplit