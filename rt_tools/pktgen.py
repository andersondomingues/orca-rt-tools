import networkx as nx
import sys
import json
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
from terminal import info

DEBUG = False

# extract flows from a given application graph edges
# returns a list of flows
def extractFlows(edges):
  flows = []
  for e in edges:
    source, target, data = e

    flow = ({
      "name" : data["label"],  # name of the flow, must be unique among the flows
      "source" : source,       # task that generates the flow (task id)
      "target" : target,       # task that will receive the packets (task id)  
      "period" : data["period"],       # packets injection period
      "datasize" : data["datasize"],   # number of bytes to send
      "deadline" : data["deadline"] }) # deadline
    flows.append(flow)

  # sort flows by label (usually f1, f2, ...)
  flows.sort(key=lambda x : x["name"], reverse=False)
  return flows

# checks whether a vector constains only "-1" values
def nulline(i):
  res = True
  for j in i:
    if j != -1:
      res = False
      break
  return res

# generates packets for a given list of flows. packets 
# are generated for the whole hyperperiod hp
def getPacketsFromFlows(flows, hp):
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

  return packets

# returns a matrix whose dimensions are equals to the given matrix
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
  flows = extractFlows(app.edges(data=True))
  
  # calculate hyperperiod
  periods = []
  for f in flows:
    periods.append(f["period"])

  hp = lcm(periods)
  info("Hyperperiod for the flow set is " + str(hp))

  # get packets from flows
  packets = getPacketsFromFlows(flows, hp)
  info("Extracted " + str(len(packets)) + " packets from " + str(len(flows)) + " flows")

  # get traversal path of each packet
  ppaths = []

  for p in packets:
    sourceTaskName = ""
    targetTaskName = ""

    for n in app.nodes(data=True):
      id, data = n
      if id == p["source"]:
        sourceTaskName = id
      if id == p["target"]:
        targetTaskName = id

    sourceNode = getMap(sourceTaskName, mapping)
    targetNode = getMap(targetTaskName, mapping)

    ppath = XY(sourceNode, targetNode, arch)
    ppaths.append(ppath)



  return 


  # enumerate network links
  nlinks = []
  for e in arch.edges(data=True):
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
        esource, etarget, edata = k
        if dj["label"] == edata["label"]:
          occupancy[ik][ic] = OCCUPANCY_MARK
        ik += 1
    ic += 1

  # fill occupancy for node-to-pe and pe-to-node links
  i = len(nlinks)
  for node in arch.nodes(data=True):
    n, d = node
    nlinks.append(['L', n, {'label': "L-" + str(n)}])
    nlinks.append([n, 'L', {'label': str(n) + "-L"}])
    occupancy.append([0 for j in range(len(packets))])
    occupancy.append([0 for j in range(len(packets))])

    j = 0
    for p in packets:

      sourceTaskName = ""
      targetTaskName = ""

      for nn in app.nodes(data=True):
        id, data = nn
        if id == p["source"]:
          sourceTaskName = id
        if id == p["target"]:
          targetTaskName = id

      source = getMap(sourceTaskName, mapping)
      if int(source) == n:
        occupancy[i][j] = OCCUPANCY_MARK

      target = getMap(targetTaskName, mapping)
      if int(target) == n:
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

        sourceTaskName = ""
        targetTaskName = ""

        for n in app.nodes(data=True):
          id, data = n
          if id == p["source"]:
            sourceTaskName = id
          if id == p["target"]:
            targetTaskName = id

        source = getMap(sourceTaskName, mapping)
        target = getMap(targetTaskName, mapping)

        #! this part uses an heuristic to accelerate the analysis
        # (4 * hops) for the first flit, plus one for the last link (output)
        # 1 for the size flit to leave 
        # 1 per payload flit to leave
        routing_time = (manhattan(source, target, arch) +1)
        routing_time = (routing_time * getRoutingTime()) + 1
        occupancy[i][j] = getNumFlits(int(p["datasize"])) + routing_time + 1

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
  
  print("%------------------------ OCCUPANCY MATRICES (MINIZINC)")
  # generate header 
  header = ""
  for p in packets:
    header = header + p["name"] + " "

  # variables
  number_of_blank_lines_skipped = 0
  print("% ", header)
  print("occupancy = ")
  print("[", end = '')
  c = 0
  first_line = True
  for i in occupancy:
    if not nulline(i): ##prints only if non-empty
      if not first_line:
        print(" ", end = '')
      print("| ", end = '')     
      for j in i:
        print("%5d, " % j, end = '')
      print(" %", nlinks[c][2]["label"])
      first_line = False
    else:
      #count only this time, not necessary to repeat the process
      number_of_blank_lines_skipped = number_of_blank_lines_skipped + 1
    c = c + 1
  print("|];")

  print("% ", header)
  print("min_start = ")
  print("[", end = '')
  c = 0
  first_line = True
  for i in min_start:
    if not nulline(i): ##prints only if non-empty
      if not first_line:
        print(" ", end = '')
      print("| ", end = '')     
      for j in i:
        print("%5d, " % j, end = '')
      print(" %", nlinks[c][2]["label"])
      first_line = False
    c = c + 1
  print("|];")

  print()

  blanks = 0
  print("% ", header)
  print("deadline = ")
  print("[", end = '')
  c = 0
  first_line = True
  for i in deadline:
    if not nulline(i): ##prints only if non-empty
      if not first_line:
        print(" ", end = '')
      print("| ", end = '')     
      for j in i:
        print("%5d, " % j, end = '')
      print(" %", nlinks[c][2]["label"])
      first_line = False
    c = c + 1
  print("|];")

  #scalars
  print()
  print("hyperperiod_length = ", hp, end = '')
  print(";")
  print("num_links = ", len(nlinks) - number_of_blank_lines_skipped, end = "")
  print(";")
  print("num_packets = ", len(packets),  end = "")
  print(";")
  print()

  #report link usage
  acc = 0
  for i in occupancy:
    for j in i:
      if j != -1:
        acc = acc + j
  
  total_net_capacity = len(occupancy) * len(occupancy[0]) * hp
  accumulated_usage = acc
  #print("Usage: ", (accumulated_usage / total_net_capacity) * 100, "%")

  with open('packets.txt', 'w+') as file:
    for p in packets:
      s = json.dumps(p)
      file.write(s + '\n')