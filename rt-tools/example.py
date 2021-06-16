import networkx as nx
import sys
import os.path
from os import path
import pygraphviz

def parseGraph(graphFile):
  return nx.read_gml(graphFile)
  
def exportGraph(graph, filename):
  gvizGraph = nx.nx_agraph.to_agraph(graph)
  gvizGraph.layout(prog = "dot") #defaults to neato
  gvizGraph.draw(filename)

def main():
  if len(sys.argv) < 2:
    print("usage:")
    print("  python3 " + sys.argv[0] + " <input_file>")
  
  if not path.exists(sys.argv[1]):
    print("unable to read input file")
    exit(0)
  
  graph = parseGraph(sys.argv[1])
  exportGraph(graph, "file.png")

  print(graph.nodes[0])

if __name__ == "__main__":
  main()
