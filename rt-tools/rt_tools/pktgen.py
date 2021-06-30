import networkx as nx
import sys
import os.path
from os import path
import mapping
from mapping import parseMap
from mapping import getMap
import routing
from routing import XY
from routing import getNumFlits
from routing import manhattan
from routing import getRoutingTime
import lcm
from lcm import lcm

DEBUG = True

# generate a list of packets from models
def pktGen(appfile, mapfile, archfile):

  if not path.exists(appfile):
    print("unable to read application file")
    exit(0)

  if not path.exists(mapfile):
    print("unable to read mapping file")
    exit(0)

  if not path.exists(archfile):
    print("unable to read architecture file")
    exit(0)

  arch = nx.read_gml(archfile) # read topology file (architecture)
  mapping = parseMap(mapfile)  # read mapping file (node-to-tasks)
  app = nx.read_gml(appfile)   # read application model
  
  # locate flows within application
  flows = []
  for e in app.edges.items():
    edge, data = e
    flow = ({"name" : data["label"], "source" : edge[0], "target" : edge[1], 
      "period" : data["period"], "datasize" : data["datasize"], 
      "deadline" : data["deadline"] })
    flows.append(flow)

  # sort flows by lable (usually f1, f2, ...)
  flows.sort(key=lambda x : x["name"], reverse=False)

  # calculate hyperperiod
  periods = []
  for f in flows:
    periods.append(f["period"])
  hp = lcm(periods)

  # get packets from flows
  packets = []

  for f in flows:
    min_start = 0 
    period = 0
    i = 0
    while min_start < hp:
      packet = ({"name" : f["name"] + ":" + str(i), "flow" : f["name"], 
        "source" : f["source"], "target" : f["target"],
        "min_start" : min_start, "abs_deadline" : min_start + f["deadline"]})
      packets.append(packet)
      min_start = min_start + f["period"]
      i = i + 1

  # get traversal path of each packet
  ppaths = []

  for p in packets:
    sourceNode = getMap(p["source"], mapping)
    targetNode = getMap(p["target"], mapping)
    print(sourceNode, targetNode, f["source"], f["target"])
    ppath = XY(sourceNode, targetNode, arch)
    ppaths.append(ppath)

  #!!
  if DEBUG:
    print("------------------------- FLOWS")
    for f in flows:
      print(f)

    print("------------------------- HYPERPERIOD")
    print(hp)

    print("------------------------- PACKETS")
    for p in packets:
      print(p)

    print("------------------------- PATHS")
    for p in ppaths:
      print(p)
    
