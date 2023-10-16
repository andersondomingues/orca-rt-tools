from os import system
from os.path import exists
from sys import argv
from gcm.graph import Graph
from gcm.gicc import GraphICC, CriteriaICC
from gcm.terminal import error, info, warn, debug
from gcm.sim import AppTask, AppMessage, AppMessageType, UCX_OS, KernelTracer


def bench_main(args):

    # import collapsed graph
    g = Graph.parse_from_file(args[0] + ".clustered")
    h = Graph.parse_from_file(args[0])

    for cn in g._nodes:  # clustered nodes
        task_set = cn._data["label"].split(":")
        task_nodes = [n for n in h._nodes if n._data["label"] in task_set]

        msgs = []
        tasks = []

        for n in task_nodes:
            tasks.append(AppTask(
                n._data["label"],
                int(n._data["wcet"])
            ))

        # for each node, find edges that goes in-out the cluster
        for e in h._edges:
            if (e._from in task_nodes and e._to not in task_nodes):
                msgs.append(AppMessage(
                    AppMessageType.OUTGOING,
                    e._data["payload"],
                    [x for x in tasks if x._name == e._from._data["label"]][0]
                ))
            elif (e._to in task_nodes and e._from not in task_nodes):
                msgs.append(AppMessage(
                    AppMessageType.INCOMING,
                    e._data["payload"],
                    [x for x in tasks if x._name == e._to._data["label"]][0]
                ))

        sim = KernelTracer(tasks, msgs, UCX_OS)
        print(sim.trace())
        print("---")


def gcm_main(argv):

    filename: str = argv[0]
    numnodes: int = int(argv[1])
    criteria: str = argv[2]

    if (not exists(filename)):
        error(f"Unable to open file `{filename}`. Aborting.")
        exit(0)

    p_criteria = None

    if (criteria == "MIN_CPU_USAGE"):
        p_criteria = CriteriaICC.MIN_CPU_USAGE
    elif (criteria == "MAX_NET_USAGE"):
        p_criteria = CriteriaICC.MAX_NET_USAGE
    else:
        p_criteria = CriteriaICC.MIN_CPU_USAGE

    g: Graph = Graph.parse_from_file(filename)
    g.export_to_dot(filename + ".dot")

    while (len(g._nodes) > numnodes):
        g = GraphICC.collapse(g, p_criteria)

    Graph.save_to_file(filename + ".clustered", g)
    g.export_to_dot(filename + ".clustered.dot")

    # export dots to png
    system(f"dot -Tpng {filename}.dot > {filename}.dot.png")
    system(f"dot -Tpng {filename}.clustered.dot > "
           + f"{filename}.clustered.dot.png")


if __name__ == "__main__":
    g = gcm_main(argv[1::])
    bench_main(argv[1::])
