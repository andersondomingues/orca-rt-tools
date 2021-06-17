import networkx as nx
import sys
import os.path
from os import path
import pygraphviz

# Exports a graph to a png file. By design, dot generates
# plot layout (requires graphviz)
def export(infile, outfile):
  if not path.exists(infile):
    print("unable to read input file")
    exit(0)

  graph = nx.read_gml(infile)
  gvizGraph = nx.nx_agraph.to_agraph(graph)
  gvizGraph.layout(prog = "dot") #defaults to neato if ommited
  gvizGraph.draw(outfile)
