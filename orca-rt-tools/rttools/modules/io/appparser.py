from rttools.terminal.terminal import error, info, warn
from os.path import exists as file_exists
from os import remove as delete_file
import networkx as nx
import sys 
import csv
import io

NEWLINE = '\n'

sys.path.append('../lib')

def loadFromFile(app_csv):

  # print(app_csv)

  if not file_exists(app_csv):
    error('Unable to load application csv file. Could not locate file "' + app_csv + '".')
    exit(1)
  else: 
    gml = csv2app(app_csv)

    tmpFile = ".__tmp"

    with open(tmpFile, "w+") as f:
      f.write(gml)


    
    graph = nx.read_gml(tmpFile)
    delete_file(tmpFile)

    # for n in graph.nodes(data=True):
    #   print(n)

    appname = (app_csv.split('/')[-1]).split('.')[0] #TODO:!
    return graph, appname

def getTaskIdByName(taskName, tasks):
  
  for t in tasks:
    if t["label"] == taskName:
      return t["id"]
  raise Exception("A tasks with name '" + taskName + "' could not be located within the task set. // " + str(tasks))

# def parseTaskRow(par):
#   return {
#     "id" : par[0],
#     "period" : par[1],
#     "capacity" : par[2],
#     "deadline" : par[3],
#     "label" : par[4],
#     "description" : par[5]
#   }

def parseTaskRow(par):
  return {
    "id": par[0],
    "wcet" : par[1],
    "label": par[2]
  }

def parseFlowRow(par):
  return {
    "id" : par[0],
    "period" : par[1],
    "datasize" : par[2],
    "deadline" : par[3],
    "source" : par[4],
    "target" : par[5],
  }

def exportGmlTasks(tasks):
  gmlTasks = []
  for t in tasks:

    t_id = t['id']
    t_label = f"{t['label']}"
    t_wcet = t["wcet"].replace(',', '')

    task_text =             f"  node [{NEWLINE}"
    task_text = task_text + f"    id {t_id} {NEWLINE}"
    task_text = task_text + f"    label {t_label}{NEWLINE}"
    task_text = task_text + f"    wcet {t_wcet}{NEWLINE}"
    task_text = task_text + f"  ]"
    
    gmlTasks.append(task_text)

  return gmlTasks

def exportGmlFlows(tasks, flows):

  gmlFlows = []
  for f in flows:

    sourceTaskId = getTaskIdByName(f["source"], tasks)
    targetTaskId = getTaskIdByName(f["target"], tasks)

    gmlFlows.append(
      "  edge [" + NEWLINE +
      "    source " + sourceTaskId + NEWLINE +
      "    target " + targetTaskId + NEWLINE +
      "    label f" + str(len(gmlFlows) +1) + NEWLINE + 
      "    period "   + f["period"].replace(',', '') + NEWLINE +
      "    datasize " + f["datasize"].replace(',', '') + NEWLINE +
      "    deadline " + f["deadline"].replace(',', '') + NEWLINE +
      "  ]"
    )
  return gmlFlows

# Exports a graph to a png file. By design, dot generates
# plot layout (requires graphviz)
def csv2app(filename):
  
  tasks = []   # store parsed tasks 
  flows = []   # store parsed flows

  # mode state machine
  # 0: seeking #tasks header 
  # 1: ignoring fields header
  # 2: parsing tasks, seeks #flows header
  # 3: ignoring fields header
  # 4: parsing flows
  mode = 0

  with open(filename) as csvfile:
    rows = csv.reader(csvfile)

    for row in rows:

      # seeks #tasks header, keep ignoring lines until it
      # finds the header 
      if mode == 0:
        if row[0] == "#tasks":
          mode = 1
      # ignore fields header line
      elif mode == 1:
        mode = 2
      # parse line as a task
      elif mode == 2:
        if row[0] == "#flows":
          mode = 3
        else:
          tasks.append(parseTaskRow(row))
      # ignoring fields header line
      elif mode == 3:
        mode = 4
      # parse line as a flow
      elif mode == 4:
        flows.append(parseFlowRow(row))

  # print(tasks)

  gmlTasks = exportGmlTasks(tasks)
  gmlFlows = exportGmlFlows(tasks, flows)

  gmlFile = []
  gmlFile.append("graph ["  + NEWLINE)
  gmlFile.append("  directed 1" + NEWLINE)
  gmlFile.append("  type 1" + NEWLINE)

  for t in gmlTasks:
    gmlFile.append(t + NEWLINE)

  for f in gmlFlows:
    gmlFile.append(f + NEWLINE)

  gmlFile.append("]")

  return ''.join(gmlFile)
