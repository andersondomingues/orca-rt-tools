from sys import argv

task_names = {
	"0-0": ['F', 'D', 'B', 'A'],
	"1-1": ['J', 'G'],
	"0-1": ['C'],
	"1-0": ['H', 'I', 'E']
}

pkts = {
	1230 : {"source": "A", "target": "C"},
	4560 : {"source": "A", "target": "B"},
	7890 : {"source": "B", "target": "D"},
	1200 : {"source": "C", "target": "E"},
	3450 : {"source": "D", "target": "F"},
	6780 : {"source": "F", "target": "G"},
	9010 : {"source": "E", "target": "I"},
	2340 : {"source": "E", "target": "H"},
	5670 : {"source": "I", "target": "J"},
	8900 : {"source": "H", "target": "J"},
	1230 : {"source": "G", "target": "J"}
}

def f2na(flit_addr):
	addr = int(flit_addr, 16)
	x = addr & 0x0000FF00
	x = x >> 16
	y = addr & 0x000000FF
	return f"{x}-{y}"

def main(argv):
	
	lines = []
	with open(argv[0]) as f:
		lines = f.readlines()

	lines = [x.replace("\n","").replace("#", "").strip() for x in lines]
	lines = [x for x in lines if x.find("Elapsed") < 0]
	lines = [x for x in lines if len(x) > 0]

	lines_sched = [x for x in lines if x.find("scheduled") >= 0]
	lines_sched = [x.split(" ") for x in lines_sched]
	lines_sched = [{"time": int(x[0]), "node": x[1], "task": task_names[x[1]][int(x[3])]} for x in lines_sched]

	for x in lines_sched:
		print(x)

	lines_recv = [x for x in lines if x.find("<-") >= 0]
	lines_recv = [x.split(" ") for x in lines_recv]
	lines_recv = [{"time": x[0], "node": x[1], "tag": x[4]} for x in lines_recv]

	for x in lines_recv:
		print(x)

	lines_send = [x for x in lines if x.find("->") >= 0]
	lines_send = [x.split(" ") for x in lines_send]
	lines_send = [{"time": x[0], "node": x[1], "tag": x[4]} for x in lines_send]

	for x in lines_send:
		print(x)

	# ===
	




if __name__ == "__main__":
	main(argv[1::])
