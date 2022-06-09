import random
r = lambda: random.randint(50,200)

def getColor():
  return '#{:02x}{:02x}{:02x}'.format(r(), r(), r())

def saveSvg(res, problem, skipped = []):
 
  RECTHEIGHT = 10
  LEFT_PADDING = 10
  BARS_PADDING = 50
  
  docWidth = problem['hyperperiod']
  docHeight = len(problem['links']) * 10

  f = open('results.svg', 'w')
  f.write('<svg version="1.1" width="' + str(docWidth) + '" height="' + str(docHeight * 2+ 200) + '" xmlns="http://www.w3.org/2000/svg">\n')

  #left scale here
  for p in range(0, len(problem['links'])):
    f.write('<text x="5" y="' + str(p * 10 + LEFT_PADDING) + '" font-size="10px">' + problem['links'][p] + '</text>\n')

  for l in range(0, len(res)):
    for p in range(0, len(res[0])):
      
      name = problem['packets'][p]
      color = getColor()

      if(res[l][p] != None):
        
        x = res[l][p] + BARS_PADDING #left scale width
        y = l * RECTHEIGHT

        width = problem['occupancy'][l][p]
        height = RECTHEIGHT

        f.write('<rect width="' + str(width) + '" height="' + str(height) + '" x="' + str(x) + '" y="' + str(y) + '" fill="' + getColor() + '" />\n')
        f.write('<text width="' + str(width) + '" height="' + str(height) + '" x="' + str(x) + '" y="' + str(y + 10) + '" font-size="10px">' + name + '</text>\n')
   
  # scale here!
  ticks = 100
  y = len(res) * RECTHEIGHT + 10
  for i in range(0, problem['hyperperiod'], ticks):
    f.write('<rect width="1" height="20" x="' + str(i + BARS_PADDING) + '" y="' + str(y) + '" fill="#666" />\n')
    f.write('<text x="' + str(i + BARS_PADDING + 3) + '" y="' + str(y + 20) + '" font-size="10px">' + str(i) + '</text>\n')
  
  base = y + 70
  # not scheduled packets
  f.write('<text x="' + str(LEFT_PADDING) + '" y="' + str(base - 5) + '" font-size="10px">skipped packets:</text>\n')
  for l in range(0, len(problem['links'])):
    for p in range(0, len(skipped)):

      if(problem['occupancy'][l][p] != None):

        width = problem['occupancy'][l][p]
        height = RECTHEIGHT
        name = problem['packets'][p]
        x = problem['min_start'][l][p] + BARS_PADDING #left scale width
        y = l * RECTHEIGHT + base

        print(problem['packets'][p])

        if problem['occupancy'][l][p] != None:
          f.write('<rect width="' + str(width) + '" height="' + str(height) + '" x="' + str(x) + '" y="' + str(y) + '" fill="' + getColor() + '" style="fill-opacity: .25;" />\n')
          f.write('<text width="' + str(width) + '" height="' + str(height) + '" x="' + str(x) + '" y="' + str(y + 10) + '" font-size="10px">' + name + '</text>\n')

  f.write('</svg>\n')
  f.close()

  return