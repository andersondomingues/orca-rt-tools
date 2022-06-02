""" high level support for doing this and that. """

# generate string of whitespaces
def genwss(len):
  buf = ""
  i = 0
  for i in range(i, len):
    buf = buf + ' '
  return buf

# zero fill
def wsfill(num, pad):
  nstr = str(num)
  fill = genwss(pad - len(nstr))
  return fill + nstr

"""
Print an info on the terminal using the 
corresponding info color. 
"""
def info(msg, end='\n\r'):
  print(colors.OK + "info: " + colors.END + str(msg), end=end)

def error(msg, end='\n\r'):
  print(colors.ERROR + "error: " + colors.END + str(msg), end=end)

def header(msg, end='\n\r'):
  print(colors.HEADER + str(msg) + colors.END, end=end)

def debug(msg, end='\n\r'):
  print(colors.CYAN + "debug: " + str(msg) + colors.END, end=end)

class colors:
  HEADER = '\033[95m'
  BLUE = '\033[94m'
  CYAN = '\033[96m'
  GREEN = '\033[92m'
  YELLOW = '\033[93m'
  RED = '\033[91m'
   
  BOLD = '\033[1m'
  UNDERLINE = '\033[4m'

  END = '\033[0m'

  WARN = YELLOW
  ERROR = RED
  OK = GREEN