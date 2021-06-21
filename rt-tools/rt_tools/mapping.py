import networkx as nx
import sys
import os.path
from os import path


def getMap(task, mapping):
  for m in mapping:
    for t in m["tasks"]:
      if t == task:
        return m["node"]

def parse_Map(sourceFile):
  print("================== Mapping")
  m = parseMap(sourceFile)

  for f in entries:
    print(f)

# parses a list of entries from the given mapping file
def parseMap(sourceFile):
  if not path.exists(sourceFile):
    print("unable to read mapping file")
    exit(0)

  with open(sourceFile) as f:
    lines = f.read().splitlines() 

  entries = []
  
  for line in lines:
    split = line.split(':')
    entries.append({"node" : split[0], "tasks" : split[1].split(',')})

  return entries
