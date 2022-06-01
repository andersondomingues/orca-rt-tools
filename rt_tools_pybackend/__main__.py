from terminal import info
from search3 import search3
from os import path
from problem_syntheticA import occupancy, min_start, deadline
#from problem_dctVerify import occupancy, min_start, deadline
#from problem_carshi2 import occupancy, min_start, deadline
def main():
  
  step = 4
  num_links = len(min_start)
  num_packets = len(min_start[0])

  res, entered, ignored = search3(min_start, occupancy, deadline, step)
  
  if res == None:
    print("No solution found.")
  else:
    info("SOLUTION:")
    for i in res:
      print(i)
    info("Ignored nodes: " + str(ignored))
    info("Entered nodes: " + str(entered))

# Automatically jumps to main if called from command line
if __name__ == "__main__":
  main()
