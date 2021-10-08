import sys
import routing
from routing import decodeNodeID

# generate and save a XY noc arch into the given path
def nocgen(x, y, output):

  gml =       "graph [\n";
  gml = gml + "  directed 1\n";
  gml = gml + "  routing_algorithm \"XY\"\n";

  # add nodes to the model
  num_nodes = x * y
  for n in range(num_nodes):
    gml = gml + "  node [\n"
    gml = gml + "    id " + str(n) + "\n"
    gml = gml + "    label \"" + str(n) + "\"\n"

    node_addr = decodeNodeID(n, x, y)
    gml = gml + "    X " + str(node_addr[0]) + "\n"
    gml = gml + "    Y " + str(node_addr[1]) + "\n"

    gml = gml + "  ]\n"

  # add horizontal paths to the model
  for line in range(x):
    for column in range(y-1):

      lnode = column + (line * (x+1))
      rnode = lnode + 1

      gml = gml + "  edge [\n"
      gml = gml + "    source " + str(lnode) + "\n"
      gml = gml + "    target " + str(rnode) + "\n"
      gml = gml + "    label \"" + (str(lnode) + "-" + str(rnode)) + "\"\n"
      gml = gml + "  ]\n"

      gml = gml + "  edge [\n"
      gml = gml + "    source " + str(rnode) + "\n"
      gml = gml + "    target " + str(lnode) + "\n"
      gml = gml + "    label \"" + (str(rnode) + "-" + str(lnode)) + "\"\n"
      gml = gml + "  ]\n"

  # add vertical paths to the model 
  for column in range(y):
    for line in range(x-1):
      lnode = column + (line * (x - 1))
      rnode = lnode + (x-1) 

      gml = gml + "  edge [\n"
      gml = gml + "    source " + str(lnode) + "\n"
      gml = gml + "    target " + str(rnode) + "\n"
      gml = gml + "    label \"" + (str(lnode) + "-" + str(rnode)) + "\"\n"
      gml = gml + "  ]\n"

      gml = gml + "  edge [\n"
      gml = gml + "    source " + str(rnode) + "\n"
      gml = gml + "    target " + str(lnode) + "\n"
      gml = gml + "    label \"" + (str(rnode) + "-" + str(lnode)) + "\"\n"
      gml = gml + "  ]\n"

  gml = gml + "]";

  with open(output, "w") as text_file:
    text_file.write(gml)


