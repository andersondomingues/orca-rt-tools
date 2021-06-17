import networkx as nx
import sys
import os.path
from os import path
import pygraphviz

# returns a list of paths from 
def XY(topology, source, target):

  if not path.exists(topology):
    print("unable to read input file")
    exit(0)

  graph = nx.read_gml(topology)
  paths = []

  # locate source and target nodes within the graph
  sourceNode = (x for x in graph.nodes(data=True) if x["id"] == source)
  targetNode = (x for x in graph.nodes(data=True) if x["id"] == target)

  # starting search
  currentNode = sourceNode

  #apply routing until reaching target destination
  while currentNode != targetNode:

    if currentNode["X"] == targetNode["X"]:
      if currentNode["Y"] > targetNode["Y"]:
        nextNode = (x for x in graph.nodes(data=True) 
          if x["Y"] == currentNode["Y"] -1 and x["X"] == currentNode["X"])
      elif currentNode["Y"] < targetNode["Y"]:
        nextNode = (x for x in graph.nodes(data=True) 
          if x["Y"] == currentNode["Y"] +1 and x["X"] == currentNode["X"])

    elif currentNode["X"] > targetNode["X"]:
      nextNode = (x for x in graph.nodes(data=True) 
        if x["Y"] == currentNode["Y"] and x["X"] -1 == currentNode["X"])

    else:
      nextNode = (x for x in graph.nodes(data=True) 
        if x["Y"] == currentNode["Y"] and x["X"] +1 == currentNode["X"])
    
    print(nextNode)

    # get edge (path)
    edge = (x for x in graph.edges(data=True) 
      if x["source"] == currentNode and x["target"] == nextNode)
    
    print(edge)
    paths[-1] = edge

    currentNode = nextNode

  print(paths)