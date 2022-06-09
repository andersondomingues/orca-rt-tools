from terminal import info
from search3 import search3
from heuristics import lstf, mbul, mcpf
from prelaunchtest import prelaunchtest
from svg import saveSvg

#from problem_syntheticA import problem
#from problem_dctVerify import problem
from problem_carshi2 import problem

# lstf(solution_space),  least slack time first
# mcpf(occupancy),       most conflicting packets first
# mbul(occupancy),       most network overhead
HEURISTIC = lstf
STEP = 10
TRIES = 500

"""
Entry-point.
@step The number of values to skip when iterating thoughout the
      search space. More is faster. Skiping more values may
      prevent the algorithm from finding any solution.
"""
def main(heuristic = HEURISTIC, step = STEP, tries = TRIES):
  
  testsres = prelaunchtest(problem)
  res, skipped = search3(problem, heuristic, tries, step)
  saveSvg(res, problem, skipped)


# Automatically jumps to main if called from command line
if __name__ == "__main__":
  main()
