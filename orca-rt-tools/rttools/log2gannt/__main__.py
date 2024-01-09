
from sys import argv
from log2gannt.matplot import l2g_main

if __name__ == "__main__":
	
  if len(argv) != 2:
    print("USAGE: log-gannt <logfile>")
  else:
	  l2g_main(argv[1::])
