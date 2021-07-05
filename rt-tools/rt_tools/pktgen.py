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

# matrix copy
def mcopy(matin):
  m = []
  for i in matin:
    n = []
    for j in i:
      n.append(j)
    m.append(n)
  return m

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
        "min_start" : min_start, "abs_deadline" : min_start + f["deadline"],
        "datasize" : f["datasize"]})
      packets.append(packet)
      min_start = min_start + f["period"]
      i = i + 1

  # get traversal path of each packet
  ppaths = []

  for p in packets:
    sourceNode = getMap(p["source"], mapping)
    targetNode = getMap(p["target"], mapping)
    ppath = XY(sourceNode, targetNode, arch)
    ppaths.append(ppath)

  # enumerate network links
  nlinks = []
  for e in arch.edges.items():
    nlinks.append(e)

  # generate occupancy matrix
  occupancy = [[0 for j in range(len(ppaths))] for i in range(len(nlinks))]

  ic = 0
  kc = 0
  OCCUPANCY_MARK = 'x'

  # fill occupancy for node-to-node links
  for i in ppaths:  
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
    occupancy.append([0 for j in range(len(packets))])
    occupancy.append([0 for j in range(len(packets))])
    j = 0
    for p in packets:
      print(p)
      source = getMap(p["source"], mapping)
      if source == n:
        occupancy[i][j] = OCCUPANCY_MARK
      target = getMap(p["target"], mapping)
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
  # occupancy is (data_size / bus_width) + 1 + manhattan (source/target) 
  # manhattan is for mesh-only nets
  i = 0
  for l in nlinks:
    j = 0
    for p in packets:
      if occupancy[i][j] != -1:
        source = getMap(p["source"], mapping)
        target = getMap(p["target"], mapping)
         #! this part uses an heuristic to accelerate the analysis
        occupancy[i][j] = ((getNumFlits(f["datasize"]) -1) +
          manhattan(source, target, arch) * getRoutingTime()) 
      j += 1
    i += 1

  # generate deadline matrix (explicit in model)
  i = 0
  for l in nlinks:
    j = 0
    for p in packets:
      if deadline[i][j] != -1:
        deadline[i][j] = p["abs_deadline"]
      j += 1
    i += 1

  # generate min_start matrix (deadline of source task)
  i = 0
  for l in nlinks:
    j = 0
    for p in packets:
      if min_start[i][j] != -1:
        min_start[i][j] = p["min_start"]
      j += 1
    i += 1

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

    print("------------------------- NETWORK LINKS")
    for l in nlinks:
      print(l)

    print("------------------------- OCCUPANCY MATRICES (MINIZINC)")
    # generate header 
    header = ""
    for p in packets:
      header = header + p["name"] + " "

    # variables
    print()
    print("hyperperiod_length = ", hp, ";")
    print("num_links = ", len(nlinks), ";")
    print("num_packets = ", len(packets),  ";")
    print()

    print("% ", header)
    print("occupancy = ")
    print("[", end = '')
    c = 0
    for i in occupancy:
      if c != 0:
        print(" ", end = '')
      print("| ", end = '')
      for j in i:
        print("%5d, " % j, end = '')
      print("  %", nlinks[c][1]["label"])
      c = c + 1
    print("|];")

    print()

    print("% ", header)
    print("min_start = ")
    print("[", end = '')
    c = 0
    for i in min_start:
      if c != 0:
        print(" ", end = '')
      print("| ", end = '')
      for j in i:
        print("%5d, " % j, end = '')
      print("  %", nlinks[c][1]["label"])
      c = c + 1
    print("|];")

    print()

    print("% ", header)
    print("deadline = ")
    print("[", end = '')
    c = 0
    for i in deadline:
      if c != 0:
        print(" ", end = '')
      print("| ", end = '')
      for j in i:
        print("%5d, " % j, end = '')
      print("  %", nlinks[c][1]["label"])
      c = c + 1
    print("|];")

    print("------------------------- PKT TABLE (VHDL SIM)")
    # vhdl 
    print()
    print("constant tp : tpacket := (")
    print("-- start  size  src  tgt  deadline ")
    i = 0
    for p in packets:
      print ("(", end = '')

      #locate source task, print WCET
      sourceTask = p["source"]
      sourceNode = getMap(sourceTask, mapping)

      for n in app.nodes.items():
        node, data = n
        if node == sourceTask:
          print(str(data["deadline"]) + ", ", end = '')
          break

      #print number of flits
      print(str(getNumFlits(p["datasize"])) + ", ", end = '')

      #locate source task, print node
      print(sourceNode + ", ", end = '')

      #locate target task, print node
      targetTask = p["target"]
      targetNode = getMap(targetTask, mapping)
      print(targetNode + ", ", end = '')

      #period
      print(p["min_start"], end = '')

      if i != len(flows) - 1:
        print("),", end = '')
      else:
        print(")", end = '')

      # packet alias
      print("    -- " + p["name"])
      i = i + 1
    print(");")
    
