import networkx as nx
import sys
import os.path
from os import path
import mapping
from mapping import parseMap

# returns a list of paths from 
def generateOccupancy(appfile, mapfile, archfile):

  if not path.exists(appfile):
    print("unable to read application file")
    exit(0)

  if not path.exists(mapfile):
    print("unable to read mapping file")
    exit(0)

  if not path.exists(archfile):
    print("unable to read architecture file")
    exit(0)

  arch = nx.read_gml(archfile)
  mapping = parseMap(mapfile)
  app = nx.read_gml(appfile)
  
  flows = []

  # locate flows within application
  for e in app.edges.items():
    edge, data = e
    flow = ({"name" : data["label"], "source" : edge[0], "target" : edge[1], 
      "period" : data["period"], "datasize" : data["datasize"], "deadline" : data["deadline"] })
    flows.append(flow)

  flows.sort(key=lambda x : x["name"], reverse=False)
  print(flows)

  # for each flow, locate source and target nodes,
#   for f in flows:
    
  # and generate paths using topology

  # create min_start table using app data

  # calculate flow times using topology info (hardcoded?)

  # calculate deadline using app data
