import matplotlib.pyplot as plt
import matplotlib

from sys import argv

KERNEL_SCHED_TIME = 200

task_names = {
	"0-0": ['IDLE', 'F', 'D', 'B', 'A'],
	"1-1": ['IDLE', 'J', 'G'],
	"0-1": ['IDLE', 'C'],
	"1-0": ['IDLE', 'H', 'I', 'E']
}

colors = [
	'firebrick',
	'forestgreen',
	'chocolate',
	'deepskyblue',
	'mediumblue',
	'darkviolet',
]

# pkts = {
# 	1230 : {"source": "A", "target": "C"},
# 	4560 : {"source": "A", "target": "B"},
# 	7890 : {"source": "B", "target": "D"},
# 	1200 : {"source": "C", "target": "E"},
# 	3450 : {"source": "D", "target": "F"},
# 	6780 : {"source": "F", "target": "G"},
# 	9010 : {"source": "E", "target": "I"},
# 	2340 : {"source": "E", "target": "H"},
# 	5670 : {"source": "I", "target": "J"},
# 	8900 : {"source": "H", "target": "J"},
# 	1230 : {"source": "G", "target": "J"}
# }

def f2na(flit_addr):
	addr = int(flit_addr, 16)
	x = addr & 0x0000FF00
	x = x >> 16
	y = addr & 0x000000FF
	return f"{x}-{y}"

def l2g_main(argv):
		
	lines = []
	with open(argv[0]) as f:
		lines = f.readlines()

	# parse scheduling events
	lines = [x.replace("\n","").replace("#", "").strip() for x in lines]
	lines = [x for x in lines if x.find("Elapsed") < 0]
	lines = [x for x in lines if x.find("workflow") < 0]
	lines = [x for x in lines if len(x) > 0]

	lines_sched = [x for x in lines if x.find("scheduled") >= 0]
	lines_sched = [x.split(" ") for x in lines_sched]
	lines_sched = [{"time": int(x[0]), "node": x[1], "task": task_names[x[1]][int(x[3])]} for x in lines_sched]

	# split task scheduling in bins
	bins = {
		"0-0" : [],
		"0-1" : [],
		"1-1" : [],
		"1-0" : []
	}

	# add scheduling to bins (also add unique elem-names)
	for x in lines_sched:
		bins[x["node"]].append({
			"time": x["time"],
			"node": x["node"],
			"task": x["task"],
			"time_e": x["time"]
		})

	# create criterion to sort events
	def sort_by_initial_time(e):
		return e["time"]

	# sort events in each bin
	for b in bins.keys():
		bins[b] = sorted(bins[b], key=sort_by_initial_time)

	# update events endtime
	for b in bins.keys():
		current_event = None
		for e in bins[b]:
			if current_event == None:
				current_event = e
			else:
				current_event["time_e"] = e["time"]
				current_event = e
				
	# create master figure
	fig, gnt = plt.subplots(4, 1, sharex=True, figsize=(12,8))
	fig.tight_layout(pad=1.0)
	plt.ticklabel_format(scilimits=(-99999999,99999999)) # prevents scientific notation
	plt.subplots_adjust(left=0.06, bottom=0.06, wspace=0.4, hspace=0.4)


	# locate min and max values 
	vmin = None
	vmax = None
	
	for b in bins.keys():
		print(bins[b])
	
	for b in bins.keys():	
		min_time = bins[b][0]["time"]
		if(vmin == None or vmin > min_time):
			vmin = min_time

		max_time = bins[b][-1]["time_e"]
		if(vmax == None or vmax < max_time):
			vmax = max_time

	k_idx = 0
	for k in bins.keys():

		# pe coordinates
		x = int(k.split("-")[0])
		y = int(k.split("-")[1])
		
		# Y-axis config.
		gnt[k_idx].set_ylim(1, len(task_names[k]))
		gnt[k_idx].set_yticks(range(-1, len(task_names[k])))
		gnt[k_idx].set_yticklabels([" "] + task_names[k])
		gnt[k_idx].set_ylabel("Tasks, PE=" + k)

		# X-axis config.
		gnt[k_idx].set_xlim(vmin, vmax)
		gnt[k_idx].set_xlabel("Time")
		gnt[k_idx].xaxis.set_major_formatter(lambda x, pos: str(f"{x / 1000000} ms")) # \u03BC

		gnt[k_idx].grid(True)
		gnt[k_idx].set_axisbelow(True)

		for e in bins[k]:
			p_height = task_names[k].index(e["task"])
			gnt[k_idx].broken_barh([(e["time"], e["time_e"] - e["time"])], (p_height - 0.3, 0.6), facecolors =(colors[p_height]))
			# gnt[k_idx].broken_barh([(e["time"], e["time"])], (p_height - 0.4, 0.8), facecolors =('black'))

		k_idx = k_idx + 1

	plt.savefig("gannt2.png", dpi=300)	

