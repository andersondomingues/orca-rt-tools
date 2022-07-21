from lib.terminal import error, info, warn
from modules.instances.routing import getNumFlits
import networkx as nx
import copy

def createInstance(app, noc, frequency):

  # convert seconds into cycles (frequency divided by one second)
  # division intended, do not remove
  scale = frequency / 1 

  tasks = []
  flows = []

  # copy nodes to instance (nothing to do for nodes)
  for n in app.nodes(data=True):
    id, data = n
    tasks.append((id, {
      'alias'   : data['alias'],
      'period'  : data['period'],
      'capacity': data['capacity'],
      'deadline': data['deadline'],
    }))

  # copy edges to instance
  # - adjust period and deadline to cycles
  # - adjust data accordingly to routing rules
  for e in app.edges(data=True):
    source, target, data = e
    
    flows.append((
      source,
      target,
      {
        'label'   : data['label'] ,
        'period'  : int(float(data['period']) * scale),
        'datasize': data['datasize'],
        'deadline': int(float(data['deadline']) * scale)
      }
    ))

  return {
    'tasks': tasks, 
    'flows' : flows
  }