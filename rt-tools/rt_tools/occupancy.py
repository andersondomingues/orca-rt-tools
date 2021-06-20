import networkx as nx
import sys
import os.path
from os import path
import mapping
from mapping import parseMap
from mapping import getMap
import routing
from routing import XY

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
      "period" : data["period"], "datasize" : data["datasize"], 
      "deadline" : data["deadline"] })
    flows.append(flow)

  # sort flows by lable (usually f1, f2, ...)
  flows.sort(key=lambda x : x["name"], reverse=False)

  print("================== Flows")
  for f in flows:
    print(f)

  # get mapping
  print("================== Extracted Map")
  mapp = {}
  for f in flows:
    source = f["source"]
    mapp[source] = getMap(source, mapping)
    target = f["target"]
    mapp[target] = getMap(target, mapping)
  
  print(mapp)

  print("================== Flow paths")   
  # for each flow, locate source and target nodes
  fpaths = []
  for f in flows:
    fpath = XY(mapp[f["source"]], mapp[f["target"]], arch)
    fpaths.append(fpath)

  for f in fpaths:
    print(f)

  # create min_start table using app data

  # calculate flow times using topology info (hardcoded?)

  # calculate deadline using app data
