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

def mcopy(matin):
  m = []
  for i in matin:
    n = []
    for j in i:
      n.append(j)
    m.append(n)
  return m

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

  # get mapping
  mapp = {}
  for f in flows:
    source = f["source"]
    mapp[source] = getMap(source, mapping)
    target = f["target"]
    mapp[target] = getMap(target, mapping)

  # for each flow, get paths 
  fpaths = []
  for f in flows:
    fpath = XY(mapp[f["source"]], mapp[f["target"]], arch)
    fpaths.append(fpath)

  # enumerate network links
  nlinks = []
  for e in arch.edges.items():
    nlinks.append(e)

  # generate occupancy matrix
  occupancy = [[0 for j in range(len(fpaths))] for i in range(len(nlinks))]
   
  ic = 0
  kc = 0
  OCCUPANCY_MARK = 'x'

  # fill occupancy for node-to-node links
  for i in fpaths:  
    for j in i:
      dj = j["data"]
      ik = 0
      for k in nlinks:
        ek, dk = k
        if dj["label"] == dk["label"]:
          occupancy[ik][ic] = OCCUPANCY_MARK
        ik += 1
    ic += 1

  # fill occupancy for node-to-pe and pe-to-node links
  i = len(nlinks)
  for node in arch.nodes.items():
    n, d = node
    nlinks.append([(n, 'L'), {'label': n + "-L"}])
    nlinks.append([('L', n), {'label': "L-" + n}])
    occupancy.append([0 for j in range(len(fpaths))])
    occupancy.append([0 for j in range(len(fpaths))])
    j = 0
    for f in flows:
      source = getMap(f["source"], mapping)
      if source == n:
        occupancy[i][j] = OCCUPANCY_MARK
      target = getMap(f["target"], mapping)
      if target == n:
        occupancy[i+1][j] = OCCUPANCY_MARK
      j += 1
    i += 2

  # generate occupancy matrices
  min_start = mcopy(occupancy)
  deadline = mcopy(occupancy)

  #fix sparse representation for all matrices
  i = 0
  for ii in min_start:
    j = 0
    for jj in ii:
      if occupancy[i][j] == 0:
        occupancy[i][j] = -1
        deadline[i][j] = -1
        min_start[i][j] = -1
      j += 1 
    i += 1

  # generate occupancy matrix
  # !! occupancy is (data_size / bus_width) + 1 + manhattan (source/target) 
  i = 0
  for l in nlinks:
    j = 0
    for f in flows:
      print(f)
      if occupancy[i][j] != -1:
        source = getMap(f["source"], mapping)
        target = getMap(f["target"], mapping)
        occupancy[i][j] = ((getNumFlits(f["datasize"]) -1) +
          manhattan(source, target, arch) * getRoutingTime()) 
      j += 1 
    i += 1

  # generate deadline matrix
  i = 0
  for l in nlinks:
    j = 0
    for f in flows:
      if deadline[i][j] != -1:
        #!! deadline is the beggining of the next task
        #deadline[i][j] = f["dealine"]
        print(f)
      j += 1 
    i += 1

  # generate min_start matrix
  i = 0
  for l in nlinks:
    j = 0
    for f in flows:
      if deadline[i][j] != -1:
        #!! min_start is the end of the source task
        #deadline[i][j] = f["dealine"]
        print(f)
      j += 1 
    i += 1

  print("================== Mapping")
  for entry in mapping:
    print(entry)

  print("================== Flow paths")   
  for f in flows:
    print(f)

  print("================== Reverse Map")
  print(mapp)

  print("================== Flows")
  for f in flows:
    print(f)

  print("================== Network links")
  for l in nlinks:
    print(l)    

  print("================== Occupancy")
  for i in occupancy:
    print(i)

  print("================== Min_Start")
  for i in min_start:
    print(i)

  print("================== Deadline")
  for i in deadline:
    print(i)


