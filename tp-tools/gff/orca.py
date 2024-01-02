from gsl.graph import Graph, GraphEdge, GraphNode

def import_graph(filename: str) -> Graph:
    g: Graph = Graph()

    PARSE_FIRST_HEADER = 1
    PARSE_NODES = 2
    PARSE_EDGES = 3

    with (open(filename, mode='r') as f):
        lines = f.readlines()

        state = PARSE_FIRST_HEADER

        for line in lines:
            if line.strip() != "":
                if state == PARSE_FIRST_HEADER:
                    if line.startswith("#"):
                        state = PARSE_NODES
                elif state == PARSE_NODES:
                    if line.startswith("#"):
                        state = PARSE_EDGES
                    else:
                        # parse nodes here
                        v = line.replace("\n", "").split(" ")
                        n: GraphNode = GraphNode(g.get_new_id(), {
                            "label": v[0],
                            "wcet": v[1]
                        })
                        g._nodes.append(n)
                elif state == PARSE_EDGES:
                    # parse edges here
                    v = line.replace("\n", "").split(" ")
                    nfrom = [x for x in g._nodes
                                if x._data["label"] == v[0]][0]  # label
                    nto = [x for x in g._nodes  
                            if x._data["label"] == v[1]][0]    # label
                    e: GraphEdge = GraphEdge(g.get_new_id(), {
                        "label": v[0] + "-" + v[1],
                        "payload": v[2]
                    }, nfrom, nto)
                    g._edges.append(e)
    return g


def export_graph(filename: str, graph: Graph) -> None:
    with (open(filename, mode='w+') as f):
        f.write("# nodes\n")
        for n in graph._nodes:
            f.write(n._data["label"] + " " + n._data["wcet"] + "\n")
        f.write("\n")
        f.write("# edges\n")
        for e in graph._edges:
            f.write(e._from._data["label"] + " "
                    + e._to._data["label"] + " "
                    + e._data["payload"] + "\n")
