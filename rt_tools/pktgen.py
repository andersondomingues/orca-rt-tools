from asyncio import subprocess
import networkx as nx
import json
from os import path
from mapping import parseMap
from mapping import getMap
from routing import XY
from routing import getNumFlits
from routing import manhattan
from routing import getRoutingTime
from lcm import lcm
from terminal import info, wsfill, error, debug
from exports import printSched, exportGraphImage
from parseznc import parseznc, parseoccup
import subprocess

DEBUG = True
ZINC_APP   = 'minizinc'
ZINC_MODEL  = '../minizinc/CM/CM-v20211013.mzn'
ZINC_SOLVER = 'Gecode'
ZINC_INPUT_PAD = 7
OCCUPANCY_TEMPLATE_PLACEHOLDER = 'X'

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

def genTable(label, table, nlinks, header):

  info("... " + label + " matrix")
  
  lines = []
  lines.append(header)
  lines.append(label + " = ")
  
  c = 0
  first_line = True
  for i in table:
    if not nulline(i): ##prints only if non-empty
      if not first_line:
        line = " "
      else:
        line = "["
      line = line + "| "
      for j in i:
        line = line + wsfill(j, ZINC_INPUT_PAD) + ", "
      line = line + " %" + nlinks[c][2]["label"]
      lines.append(line)
      first_line = False
    c = c + 1
  lines.append("|];")

  return '\n'.join(lines, )

# generate a list of packets from models
def pktGen(appfile, mapfile, archfile):

  if not path.exists(appfile):
    error("Could not read application file")
    exit()

  if not path.exists(mapfile):
    error("Could not read mapping file")
    exit()

  if not path.exists(archfile):
    error("Could not read architecture file")
    exit()

  info("Reading `" + appfile + "`")
  app = nx.read_gml(appfile)   # read application model
  info("Reading `" + archfile + "`")
  arch = nx.read_gml(archfile) # read topology file (architecture)
  info("Reading `" + mapfile + "`")
  mapping = parseMap(mapfile)  # read mapping file (node-to-tasks)
  

  info("Exporting PNG file for `" + appfile + "`")
  appname = (appfile.split('/')[-1].split('.')[0])
  exportGraphImage(appfile, "../applications/" + appname + ".png")

  # locate flows within application
  flows = extractFlows(app.edges(data=True))
  
  if DEBUG == True:
    for f in flows:
      debug(str(f))

  # calculate hyperperiod
  periods = []
  for f in flows:
    periods.append(f["period"])

  hp = lcm(periods)
  info("Hyperperiod for the entered flow set is " + str(hp))

  # get packets from flows
  packets = getPacketsFromFlows(flows, hp)
  info("Extracted " + str(len(packets)) + " packets from " + str(len(flows)) + " flows")

  if DEBUG == True:
    for p in packets:
      debug(str(p))

  info("Discovering packets routes...")

  # get traversal path of each packet
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

    p['path'] = ppath

    if DEBUG == True:
      debug(p['name'] + ": hops=" + str(len(ppath)))
      for p in ppath:
        debug("    " + str(p))

  info("Enumerating network links...")

  # enumerate network links
  nlinks = []
  for e in arch.edges(data=True):
    nlinks.append(e)

  # add local-to/from links 
  for n in arch.nodes(data=True):
    x, y = n
    nlinks.append((x, 'L', {'label': str(x) + '-L'}))
    nlinks.append(('L', x, {'label': 'L-' + str(x)}))

  if DEBUG == True:
    for n in nlinks:
      debug(str(n))

  info("... Discovered " + str(len(nlinks)) + " links")


  # calculate net_time
  info("Calculating networking time...")
  
  for p in packets:
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

    routing_time = (manhattan(source, target, arch) +1)
    routing_time = (routing_time * getRoutingTime()) + 1
    p['net_time'] = getNumFlits(int(p["datasize"])) + routing_time + 1

    if DEBUG == True:
      debug(p['name'] + ": " + str(p['net_time']))

  info("Generating optimization problem (Minizinc export)...")

  # Generate template matrix, represents the relation P x R, where 
  # P is the set of all packets and R is the set of all resources. 
  # Resources are represented by links, thus the len(nlinks).
  occupancy = [[0 for j in range(len(packets))] for i in range(len(nlinks))]

  # fill occupancy template
  for i in range(0, len(packets)):
    p = packets[i]
    for j in range(0, len(nlinks)):
      n = nlinks[j]
      for t in p['path']:
        q = n[2]
        if(q['label'] == t['data']['label']):
          occupancy[j][i] = OCCUPANCY_TEMPLATE_PLACEHOLDER

  # fix sparse matrix representation
  for p1 in occupancy:
    for p2 in p1:
      if occupancy[p1][p2] != OCCUPANCY_TEMPLATE_PLACEHOLDER:
        occupancy[p1][p2] = -1

  # generate occupancy matrices
  min_start = mcopy(occupancy)
  deadline = mcopy(occupancy)
    

  # populate occupancy, deadline, and min_start tables


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
  
  # generate header 
  header = "% "
  for p in packets:
    header = header + p["name"] + " "
  
  tOccupancy = genTable("occupancy", occupancy, nlinks, header)
  tDeadline = genTable("deadline", deadline, nlinks, header)
  tMinStart = genTable("min_start", min_start, nlinks, header)

  skipLines = 0
  for l in occupancy:
    if(nulline(l)):
      skipLines = skipLines + 1

  info('Skipping ' + str(skipLines) + ' unused network links')

  lines = []
  lines.append("hyperperiod_length = " +  str(hp) + ";")
  lines.append("num_links = " + str(len(nlinks) - skipLines) + ";")
  lines.append("num_packets = " + str(len(packets)) + ";")
  lines.append("")
  lines.append(tOccupancy)
  lines.append("")
  lines.append(tDeadline)
  lines.append("")
  lines.append(tMinStart)

  # write minizinc input to disk
  mzFile = '../minizinc/' + appname + '.dzn'
  info("Writing to `" + mzFile + "`")
  with open(mzFile, 'w+') as file:
    for l in lines:
      file.write(l + '\n')

  info("Checking for Minizinc installation...")
  try:
    sp = subprocess.run([ZINC_APP, '--version'], stdout=subprocess.PIPE)
    version = sp.stdout.decode('utf-8').split("\n")
    for l in version:
      if len(l) > 0:
        info("... " + l)
  except:
    error("Unable to locate Minizinc installation in this system, aborting")
    exit()

  info("Invoking Minizinc with...")
  cmd = [ZINC_APP, "--solver", ZINC_SOLVER, ZINC_MODEL, mzFile]
  info("... `" + " ".join(cmd) + "`")
  info("Waiting for " + ZINC_APP + " to finish processing, please wait (it may take a while)")
  sp = subprocess.run(cmd, stdout=subprocess.PIPE)  

  voccupancy = parseoccup(occupancy)
  releases = parseznc(sp.stdout.decode('utf-8'))

  info("Preparing data for plotting using `matplotlib`...")
  #final packets characterization, scheduled
  schedule = []
  for i in range(0, len(packets)):
    p = packets[i]
    r = releases[i]
    o = voccupancy[i]
    schedule.append({
      'name' : p['name'],
      'flow' : p['flow'],
      'source' : {
        p['source'],
        getMap(p['source'], mapping)
      },
      'target' : {
        p['target'],
        getMap(p['target'], mapping)
      },
      'min_start' : p['min_start'],
      'abs_deadline' : p['abs_deadline'],
      'datasize_bytes' : p['datasize'],
      'num_flit' : getNumFlits(p['datasize']),
      'release' : r,
      'net_time' : o,
      'path' : ppaths[i]
    })   

  info("Plotting...")
  printSched(schedule, hp)