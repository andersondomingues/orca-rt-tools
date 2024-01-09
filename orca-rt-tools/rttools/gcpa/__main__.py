from sys import argv

from gsl.graph import Graph, GraphEdge, GraphNode
from gff.orca import import_graph as orca_import


def get_largest_path(n, dct, graph):
    
    # if processed already, return value
    if n in dct.keys():
        return dct[n]
    
    dct[n] = -1 # flag to avoid cycles

    # find all "antecessors" of n
    ante = []
    ante_sum = 0
    for e in graph._edges:
        if e._to == n:
            ante.append(e._from)
            ante_sum = ante_sum + int(e._data["payload"])

    # find get the maximum path to 
    max_distance = 0
    max_distance_node = None

    for nn in ante:
        dist = get_largest_path(nn, dct, graph)
        if(dist == -1):
            continue

        if(dist > max_distance):
            max_distance = dct[nn]
            max_distance_node = nn

    dct[n] = max_distance + int(n._data["wcet"]) + ante_sum
    return dct[n]

    

def gcpa_main(filename: str):
    graph = orca_import(filename)

    # # find root note
    # root_nodes = [x for x in graph._nodes if len([y for y in graph._edges if y._to == x]) == 0]

    # if(len(root_nodes) > 1):
    #     raise Exception("Unable to find critical path for multiple systems containing data input tasks")
    
    # if(len(root_nodes) < 1):
    #     raise Exception("Unable to find critical path for cyclic graphs")

    # create a dictionary of nodes and values, to store the max load value
    # max load value = sum(edges) + highest value among predecessors
    # value node for root node is zero
    dct = {}

    # while len(dct.keys()) < len(graph._nodes):
    #   for n in graph._nodes:
    #       if n not in dct.keys():
    #           get_largest_path(n, dct, graph)
    for n in graph._nodes:
      get_largest_path(n, dct, graph)

    for k in dct.keys():
        print(k, dct[k])


if __name__ == "__main__":
    args = argv[1::]
    gcpa_main(args[0])