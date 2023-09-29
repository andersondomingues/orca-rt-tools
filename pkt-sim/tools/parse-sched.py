import random
from os import listdir, getcwd
from os.path import isfile, join

NOC_HEIGHT = 4
SCHED_TIME = 60

PWD = getcwd()
FOLDER = join(PWD, "../logs")


COLORS = {}
def get_color(s):
  if(s not in COLORS):
    COLORS[s] = "#" + ''.join([random.choice('ABCD0123456789') for i in range(6)])
  return COLORS[s]

def make_css():
  with open(join(PWD, "sched.css"), "w+") as fp:
    fp.write("""
      @import url('https://fonts.googleapis.com/css2?family=Poppins&display=swap');
      html, body {margin: 0px, border: 0px; padding: 0px; font-family: Poppins; background: white}
      fieldset legend { border: 1px solid gray; padding: 3px; background: #eee; margin-left:-14px; margin-top:-10px;}
      fieldset {margin-top:5px; background: #eee}
    """)


def parse_cpu_info(fname):
  _v = fname[fname.find("-"):fname.find(".")].split("-")
  x = _v[1]
  y = _v[2]

  return {
    "cpu_x" : _v[1],
    "cpu_y" : _v[2],
    "cpu_id": str(int(_v[1]) + int(NOC_HEIGHT) * int(_v[2]))
  }


def parse_sched():
  
  # pre - generate CSS file
  make_css()

  # 1 - get all log files 
  logs = [f for f in listdir(FOLDER) if isfile(join(FOLDER, f)) and f.endswith("txt")]

  def get_time(item):
    return item["time"]

  # 2 - for each file, parse the schedule
  scheds = []
  for log in logs:

    # 2.1 - open log file for reading         
    with open(join(FOLDER, log)) as fp:
      
      cpu_logs = []

      # 2.1.1 - for each line, look for the SCHED string
      line = fp.readline()

      while line:
        idx_begin = line.find("SCHED")

        if(idx_begin != -1):
          _v = line[idx_begin:line.find("##")].split(" ")

          obj = {
            "time" : _v[1],
            "task" : {
              "id" : _v[2],
              "name": _v[3],
            },            
            "cpu_info": parse_cpu_info(log)
          }

          cpu_logs.append(obj)

        line = fp.readline()
    
    scheds.append(sorted(cpu_logs, key = get_time))
  
  # 3 sort list by cpu_id
  def get_cpu_id(item):
    return int(item[0]["cpu_info"]["cpu_id"])

  scheds = sorted(scheds, key=get_cpu_id)

  # 4 - draw
  with open(join(PWD, "sched.html"), "w+") as fp:

    # 4.1 - write header 
    fp.write("<html>")
    fp.write("<head><link rel='stylesheet' href='sched.css'></head>")
    fp.write("<body>")

    # 4.2 - generate an schedule per CPU
    for s in scheds:

      cpu_id = "cpu_id: " + s[0]["cpu_info"]["cpu_id"] + " (" + s[0]["cpu_info"]["cpu_x"] + ", " + s[0]["cpu_info"]["cpu_y"] + ")"
      print(cpu_id)

      fp.write("<fieldset>")
      fp.write(f"<legend>{cpu_id}</legend>")

      max_time = len(s) * SCHED_TIME
      fp.write(f"<svg width='{max_time}' height='200'>")
        
      # 4.2.1 - generate visual rule
      for i in range(0, len(s)):
        rect_x = i * SCHED_TIME
        rect_x_text = rect_x + 3
        fp.write(f"<rect x='{rect_x}' y='10' width='1' height='20' fill='gray' />")
        fp.write(f"<text x='{rect_x_text}' y='26' height='50' fill='black'>{i}</text>")

      fp.write(f"<rect x='0' y='10' width='10000' height='1' fill='gray' />")

      # 4.2.2 - place tasks into an svg 
      for i in range(0, len(s)):
        rect_y = (int(s[i]["task"]["id"]) * 10) + 30
        rect_x = int(s[i]["time"]) * SCHED_TIME
        task_name = s[i]["task"]["name"]
        rect_y_name = rect_y + 15
        rect_x_name = rect_x + 5

        #color = 'blue'
        color = get_color(task_name)

        fp.write(f"<rect x='{rect_x}' y='{rect_y}' width='{SCHED_TIME}' height='20' fill='{color}' />")
        fp.write(f"<text x='{rect_x_name}' y='{rect_y_name}' fill='white'>{task_name}</text>")

      fp.write("</svg>")
      fp.write("</fieldset>")

    # 4.3 - write tail
    fp.write("</body>")
    fp.write("</html>")


parse_sched()