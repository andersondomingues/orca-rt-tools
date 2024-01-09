from sys import argv
from bench.engine import SingleCore


def main_bench(argv):
	filename = argv[0]
	mode = argv[1]
	algorithm = argv[2]

	# read clustered 
	clustered_filename = filename + ".clustered"
	g = Graph.import_from_file(filename)

	print(g)
	



if __name__ == "__main__":
	main_bench(argv[1::])
