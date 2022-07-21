ENABLE_PRINT_DEBUG = False

def info(msg, end='\n\r'):
  print(colors.OK + "info: " + colors.END + msg, end=end)

def error(msg, end='\n\r'):
  print(colors.ERROR + "error: " + colors.END + str(msg), end=end)

def header(msg, end='\n\r'):
  print(colors.HEADER + msg + colors.END, end=end)

def debug(msg, end='\n\r'):
  if ENABLE_PRINT_DEBUG:
    print(colors.DEBUG + "debug: " + msg + colors.END, end=end)

def warn(msg, end='\n\r'):
  print(colors.WARN + "warn: " + msg + colors.END, end=end)

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
  DEBUG = CYAN
  OK = GREEN