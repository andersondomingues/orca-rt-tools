from pktgen import pktGen
from terminal import colors
# app entry-point
def rttool(appfile, mapfile, archfile):
  print(colors.HEADER + "Welcome to RT_TOOLS r0.0.0.1-alpha" + colors.END)
  x = pktGen(appfile, mapfile, archfile)
