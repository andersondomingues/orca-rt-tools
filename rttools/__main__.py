import sys

from lib.terminal import error, header, info, warn

from modules.io import configurator, appparser, nocparser, mapparser
from modules.frequency import guesser
from modules.instances import instantiator
from modules.unwrapper import flowUnwrapper
from modules.backend.ags import ags
from modules.backend.minizinc import minizinc 

RTTOOLS_ENABLE_MINIZINC = False
RTTOOLS_PRUNNING_FACTOR = 1
RTTOOLS_FAIL_THRESHOULD = 5000000

# Main 
def main():
  header('Launching ' + sys.argv[0] + ' package...')
  args = sys.argv[1:]

  # [0] configuration file
  # [1] application characterization
  # [2] mapping
  # [3] topology
  # [4] frequency
  if(len(args) < 4 or len(args) > 5):
    error('Usage: ')
    error('  __main__.py <config> <app> <map> <noc> [<frequency>]')
    return 1

  cfg_file = args[0]
  app_file = args[1]
  map_file = args[2]
  noc_file = args[3]
  frequency = None

  if(len(args) == 5):
    frequency = int(args[4])

  # parse configuration
  info('Loading configuration file. `' + cfg_file + "`")
  cfg = configurator.loadFromFile(cfg_file)
  
  info('Loading application file `' + app_file + "`")
  app, appname = appparser.loadFromFile(app_file)

  info('Loading NoC file `' + noc_file + "`")
  noc = nocparser.loadFromFile(noc_file)

  info("Loading mapping file `" + map_file + "`")
  mapping = mapparser.loadFromFile(map_file)

  if(frequency == None):
    frequency = guesser.guess()
    warn('no default frequency indicated, scaling for ' + str(frequency) + 'Hz...')

  info("Tentative frequency is " + str(frequency) + "Hz")


  schedule = None
  while(schedule == None):
    # generate instance
    instance = instantiator.createInstance(app, noc, frequency)

    # unwrap flows into packets
    packets, hp, nlinks = flowUnwrapper.unwrap(instance, noc, mapping)

    # pre-tests here!
    #testsres = prelaunchtest(problem)

    # select which scheduler to use
    if RTTOOLS_ENABLE_MINIZINC:
      schedule = minizinc.minizincExport(packets, nlinks, hp, mapping, noc, appname)
    else: # adaptive guided search
      schedule = ags.agsExport(packets, nlinks, hp, mapping, noc, appname,
        RTTOOLS_PRUNNING_FACTOR, RTTOOLS_FAIL_THRESHOULD)

    # check whether schedule is feasible
    if schedule != None:
      #feasible
      pass
    else:
      #unfeasible
      pass

    return

  return

# Automatically jumps to main if called from command line.
# Executable script name is removed from the params list,
# and the list itself is passed to the real main() function.
if __name__ == "__main__":
  main()
