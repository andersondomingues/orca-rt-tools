import sys

from lib.terminal import error, header, info, warn

from modules.io import configurator, appparser, nocparser, mapparser, svg, systemverilog
from modules.frequency import guesser
from modules.instances import instantiator
from modules.unwrapper import flowUnwrapper
from modules.backend.ags import ags, heuristics
from modules.backend.minizinc import minizinc

RTTOOLS_ENABLE_MINIZINC = False
RTTOOLS_PRUNNING_FACTOR = 2000

RTTOOLS_FAIL_THRESHOULD = 500
RTTOOLS_SCALING_TOLERANCE = 0.01
RTTOOLS_DEFAULT_FREQUENCY = 3000000
RTTOOLS_HEURISTIC = heuristics.mbcf

def parseMinimumReleaseTime(sched, p, hp):
  min = hp
  for l in sched:
    print(l)
    if (l[p] != None and l[p] < min):
      min = l[p]
  return min

def main():
  header('Launching ' + sys.argv[0] + ' package...')
  args = sys.argv[1:]

  for i in args:
    info("-> " + i)

  # [0] application characterization
  # [1] mapping
  # [2] topology
  # [3] frequency
  if len(args) not in [3, 4]:
    error('Usage: ')
    error('  __main__.py <app> <map> <noc> [<frequency>]')
    return 1

  cfg_file = "rttools.ini"
  app_file = args[0]
  map_file = args[1]
  noc_file = args[2]
  frequency = None

  if(len(args) == 4):
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
    warn('No default frequency indicated, scaling for ' + str(frequency) + 'Hz...')

  schedule = None
  pfreq = 0
  nfreq = frequency * 2
  cfreq = frequency 
  
  last_working_frequency = None
  last_working_schedule = None
  last_working_instance = None
  last_working_hp = None

  while(True):
    # generate instance
    instance = instantiator.createInstance(app, noc, cfreq)
    info("Tentative frequency is " + str(cfreq) + "Hz")

    # unwrap flows into packets
    packets, hp, nlinks = flowUnwrapper.unwrap(instance, noc, mapping)

    if hp == 0:
      break

    # pre-tests here!
    #testsres = prelaunchtest(problem)

    # select which scheduler to use
    if RTTOOLS_ENABLE_MINIZINC:
      schedule = minizinc.minizincExport(packets, nlinks, hp, mapping, noc, appname)
    else: # adaptive guided search
      problem, schedule = ags.agsExport(packets, nlinks, hp, mapping, noc, appname,
        RTTOOLS_PRUNNING_FACTOR, RTTOOLS_FAIL_THRESHOULD, RTTOOLS_HEURISTIC)

    # print(schedule)
    if schedule != None:
      sched, skipped = schedule 

      if len(skipped) == 0:
        warn("Found a schedule at " + str(cfreq) + "Hz. Scaling frequency down.")
        last_working_frequency = cfreq
        last_working_schedule = sched
        last_working_instance = instance 
        last_working_hp = hp
        nfreq = cfreq
      else:
        #unfeasible
        warn("Could not find a schedule at " + str(cfreq) + "Hz.")
        warn("Skip list is not empty (" + str(len(skipped)) + ")!")
        warn("Scaling frequency up...")
        pfreq = cfreq
        
    else:
        #unfeasible
        warn("Could not find a schedule at " + str(cfreq) + "Hz.")
        warn("Scaling frequency up...")
        pfreq = cfreq
    
    cfreq = (nfreq + pfreq) / 2
    
    if abs(pfreq - nfreq) < cfreq * RTTOOLS_SCALING_TOLERANCE:
      break 

  if last_working_frequency != None:
    info("Unable to optmize minimum frequency any further.")
    info('Minimum frequency found at ' + str(last_working_frequency) + "Hz")

    filename = 'results.svg'
    svg.saveSvg(filename, last_working_schedule, problem, skipped, 0.001)
    info('Schedule visualization exported to `' + filename + '`')

    expDir = 'pkt-sim/packets'
    systemverilog.exportPackets(expDir, last_working_schedule, problem, last_working_frequency)
    info('SystemVerilog mimics exported to `' + expDir + '`')

  else:
    warn('Could not find a suitable frequency for the given flow set')


# Automatically jumps to main if called from command line.
# Executable script name is removed from the params list,
# and the list itself is passed to the real main() function.
if __name__ == "__main__":
  main()
