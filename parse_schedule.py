from sys import argv
from math import ceil

task_names = {
	"0-0": ['F', 'D', 'B', 'A'],
	"1-1": ['J', 'G'],
	"0-1": ['C'],
	"1-0": ['H', 'I', 'E']
}

def parse_flowS(args):
	pass

def parse_schedule(args):

	v = []

	with open(args[0]) as f:
		v = [x for x in f.readlines() if x.strip() != "" and x.find("scheduled")] 

	v = [x.replace('\n', '').replace('# ','').replace("scheduled ", "") for x in v if not x.startswith("# Elap")]
	
	v = [x.split(" ")  for x in v]
	v = [{"time": ceil(int(x[0])/100) , "cpu": x[1], "task": int(x[2])} for x in v]

	# find max 
	max_time = 0
	for i in v:
		if(i["time"] > max_time):
			max_time = i["time"]

	# print period wave
	print("{signal: [")
	# print("  {name: 'cycles*100', wave: 'p", end=max_time * ".")
	# print("'},")

	# finds cpus
	cpus = {}

	for i in v:
		if(i["cpu"] not in cpus.keys()):
			cpus[i["cpu"]] = []
		cpus[i["cpu"]].append(i)

	# for each cpu, generate wave
	for cpu in cpus.keys():
		print("  {name: 'PE ", cpu, "', wave: '", end="")
		events = cpus[cpu]
		vva = [str(e["task"] + 3) for e in events]
		vvb = ["'" + task_names[cpu][(e["task"])] + "'" for e in events]
		print("".join(vva), end="")

		print("', data: [", ",".join(vvb), "]},")

	print("], foot: {tock: 0 }}")
	

	
def main(args):
	parse_schedule(args)
	parse_flows(args)

if __name__ == "__main__":
	main(argv[1::])
