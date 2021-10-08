import networkx as nx
import sys
import os.path
from os import path
import routing
from routing import XY
import mapping
from mapping import parseMap
import occupancy
from occupancy import generateOccupancy
import pktgen
from pktgen import pktGen
import vhdl
from vhdl import exportVhdl
import nocgen
from nocgen import nocgen


def main():
  # programa requires at least one command 
  if len(sys.argv) < 2:
    print("usage:")
    print("  python3 " + sys.argv[0] + " <cmd> [<params>, ...]")
    print("available commands:")
    print("  export <infile> <outfile>")
    print("  nocgen <x> <y> <outfile>")
    print("  print <infile>")
    print("  route <infile> <source> <target>")
    print("  map <infile>")
    print("  vhdl <appfile> <mapfile> <archfile> <startfile>")
    print("  pkt <appfile> <mapfile> <archfile>")
    exit(0)
  
# plot exports given graph to a png file
  if sys.argv[1] == 'nocgen':

    if len(sys.argv) != 5:
      print("command <nocgen> requires <x>, <y> and <outfile> arguments")
      exit(0)

    nocgen(int(sys.argv[2]), int(sys.argv[3]), sys.argv[4])
  
  # plot exports given graph to a png file
  elif sys.argv[1] == 'export':

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
      print("command <route> requires <infile>, <source>, and <target> arguments")
      exit(0)

    parse_XY(sys.argv[2], sys.argv[3], sys.argv[4])
  
  elif sys.argv[1] == 'map':

    if len(sys.argv) != 3:
      print("command <map> requires <infile> argument")
      exit(0)

    parseMap(sys.argv[2])

  elif sys.argv[1] == 'vhdl':

    if len(sys.argv) != 6:
      print("command <vhdl> requires <appfile>, <mapfile>, <archfile>, and <startfile> arguments")
      exit(0)

    exportVhdl(sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])

  elif sys.argv[1] == 'pkt':

    if len(sys.argv) != 5:
      print("command <pkt> requires <appfile>, <mapfile> and <archfile> arguments")
      exit(0)

    pktGen(sys.argv[2], sys.argv[3], sys.argv[4])

  # invalid case
  else:
    print("command " + sys.argv[1] + " is invalid")

# Automatically jumps to main if called from command line
if __name__ == "__main__":
  main()
