import subprocess
from sys import argv
from gff.orca import import_graph as orca_import
from gff.orca import export_graph as orca_export
from gff.dot import export_graph as dot_export


def convert_graph(ifile: str, iformat: str, oformat: str, ofile: str) -> None:

    graph: Graph = None

    if(iformat not in ["ORCA", "DOT"]):
        raise error("Invalid input format.")

    if(iformat != "DOT" and oformat not in ["ORCA", "DOT"]):
        raise error("Invalid output format.")

    match iformat:
        case "ORCA":
            graph = orca_import(ifile)
        case "DOT":
            oformat = oformat.lower()
            cline = f"dot -T{oformat} {ifile} -o {ofile}"
            subprocess.run(cline.split(" "))

    if(iformat != "DOT"):
        match oformat:
            case "ORCA":
                orca_export(graph, ofile)
            case "DOT":
                dot_export(graph, ofile)


if __name__ == "__main__":
    
    if(len(argv) != 5):
        raise Exception("Usage: gff <ifile> <iformat> <oformat> <ofile>")

    input_file = str(argv[1])
    i_format = argv[2]
    o_format = argv[3]
    output_file = str(argv[4])

    convert_graph(input_file, i_format, o_format, output_file)