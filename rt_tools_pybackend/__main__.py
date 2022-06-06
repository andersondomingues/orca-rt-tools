from terminal import info
from search3 import search3
from heuristics import lstf, mbul, mcpf
from prelaunchtest import prelaunchtest

#from problem_syntheticA import occupancy, min_start, deadline, packets, links, hyperperiod
#from problem_dctVerify import occupancy, min_start, deadline, packets, links, hyperperiod
from problem_carshi2 import occupancy, min_start, deadline, packets, links, hyperperiod

STEP = 1000

# lstf(solution_space),  least slack time first
# mcpf(occupancy),       most conflicting packets first
# mbul(occupancy),       most network overhead
HEURISTIC = lstf

"""
Entry-point.
@step The number of values to skip when iterating thoughout the
      search space. More is faster. Skiping more values may
      prevent the algorithm from finding any solution.
"""
def main(step = STEP):
  
  testsres = prelaunchtest(min_start, occupancy, deadline, packets, links, hyperperiod)

  res, entered, ignored = search3(min_start, occupancy, deadline, HEURISTIC, packets, links, step)
  
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
