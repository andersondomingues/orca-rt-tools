import networkx as nx
import sys
import os.path
from os import path
import pygraphviz
import matplotlib.pyplot as plt


# Exports a graph to a png file. By design, dot generates
# plot layout (requires graphviz)
def exportGraphImage(infile, outfile):
  if not path.exists(infile):
    print("unable to read input file")
    exit(0)

  graph = nx.read_gml(infile)
  gvizGraph = nx.nx_agraph.to_agraph(graph)
  gvizGraph.layout(prog = "dot") #defaults to neato if ommited
  gvizGraph.draw(outfile)

def getName(packet):
  return packet['name']

def printSched(packets, hp):
  x = []
  for p in packets:
    x.append([p['release'], p['release'] + p['net_time']])

  fig, ax = plt.subplots()
  for i,evt in enumerate(x):
      ax.barh(i,width=evt[1]-evt[0],left=evt[0])

  ax.set_yticks(range(len(x)))
  ax.set_yticklabels(map(getName, packets))
  plt.show()
  return
