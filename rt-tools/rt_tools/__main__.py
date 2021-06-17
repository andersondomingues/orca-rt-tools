import networkx as nx
import sys
import os.path
from os import path
import pygraphviz
import routing
from routing import XY
import export
from export import export

def main():
  # programa requires at least one command 
  if len(sys.argv) < 2:
    print("usage:")
    print("  python3 " + sys.argv[0] + " <cmd> [<params>, ...]")
    exit(0)
  
  # plot exports given graph to a png file
  if sys.argv[1] == 'export':

    if len(sys.argv) != 4:
      print("command <export> requires <infile> and <outfile> arguments")
      exit(0)

    export(sys.argv[2], sys.argv[3])

  # outputs graph to the console
  elif sys.argv[1] == 'print':

    if len(sys.argv) != 3:
      print("command <print> requires <infile> argument")
      exit(0)

    graph = parseGraph(sys.argv[2])
    print(graph.nodes(data=True))
    print(graph.edges(data=True))

  elif sys.argv[1] == 'route':

    if len(sys.argv) != 5:
      print(sys.argv)
      print("command <route> requires <infile>, <source>, and <target> arguments")
      exit(0)

    XY(sys.argv[2], sys.argv[3], sys.argv[4])

  # invalid case
  else:
    print("command " + sys.argv[1] + " is invalid")


# Automatically jumps to main if called from command line
if __name__ == "__main__":
  main()