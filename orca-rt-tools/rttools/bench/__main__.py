from sys import argv

from rttools.terminal.terminal import header, info, error

from rttools.gff.orca import import_graph as orca_import

from rttools.bench.scheduling import RoundRobinSchedule
from rttools.bench.engine import SingleCoreEngine


def main_bench(argv):

	header("This is ORT/BENCH")

	if (len(argv) != 3) :
		info("Usage: bench <filename> <mode> <algorithm>")
	else:

		filename = argv[0]
		mode = argv[1]
		algo = argv[2]

		# read file
		graph = orca_import(filename)

		# select algorithm
		algorithm = None
	
		if(algo == "RR"):
			algorithm = RoundRobinSchedule
		else: 
			error("Unable to find algorithm '", algo, "'")

		if(algorithm != None):
			engine: SingleCoreEngine = SingleCoreEngine(graph, algorithm)
			engine.simulate(1000, True)
			
if __name__ == "__main__":
	main_bench(argv[1::])
