from sys import argv
from math import ceil

task_names = {
	"0-0": ['F', 'D', 'B', 'A'],
	"1-1": ['J', 'G'],
	"0-1": ['C'],
	"1-0": ['H', 'I', 'E']
}

# -~> label
# ~> label
# -> label
def parse_flows(args):
	pass


def create_ganttdff_groups(group_name, events):
	ll = []
	ll.append("\\ganttgroup[inline=false,group/.style={draw=none,fill=none}]{" + group_name + "}{0}{0} \n")

	time = 0

	for e in events:
		ll.append("\\ganttbar[name=" + e["task"] + "]{" + e["task"] + "}{" + time + "}{" +  + "}")

	return ll

	


def parse_schedule_latex(args):

	# parse text lines, remove garbage
	v = []
	with open(args[0]) as f:
		v = [x.replace("\n","").replace("#","").strip() for x in f.readlines() if x.strip() != "" and x.find("scheduled") > 0] 

	# separate tasks per node
	n = {}
	for tn in task_names.keys():
		n[tn] = []

	for l in v:
		vv = l.split(' ')
		obj = {
			"time": vv[0],
			"node": vv[1],
			"task": vv[3]
		}
		n[vv[1]].append(obj)

	groups = []

	# header
	
	
	# groups
	for nn in n:
		lines = create_ganttpdf_group(nn, n[nn])
		for l in lines:
			groups.append(l)





	

	


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
# 	parse_schedule(args)
	parse_schedule_latex(args)
	parse_flows(args)

if __name__ == "__main__":
	main(argv[1::])
