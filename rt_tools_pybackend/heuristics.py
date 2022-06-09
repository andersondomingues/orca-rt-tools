from math import inf
from vutils import mcopy, vcopy

def resort(tt, packets):
  t = vcopy(tt)
  h = []
  
  removed = True
  while(removed):

    removed = False
    min = +inf
    idx = +inf    

    for i in range(0, len(t)):
      if(t[i] != -inf and t[i] < min):
        min = t[i]
        idx = i
        t[i] = +inf
        removed = True

    if(removed):
      h.append(idx)
  return h

# find the sum of capacity for all links
# most bandwidth-usage link
def mbul(solution_space, min_start, O, deadline):
  sumsl = [0 for x in O]
  sumsp = [0 for x in O[0]]

  # find capacity of all links
  for l in range(0, len(O)):
    for p in range(0, len(O[0])):
      if(O[l][p] != None):
        sumsl[l] += O[l][p]
        sumsp[p] += O[l][p]


  # sorte packets from the least consuming to the most consuming
  # (most consuming will be consumed first)
  list = []

  removed = True
  while removed:
    lowest = +inf
    idx = +inf

    removed = False

    for i in range(0, len(sumsp)):
      if sumsp[i] < lowest:
        lowest = sumsp[i]
        idx = i
        
    if lowest != +inf:
      list.append(idx)
      sumsp[idx] = +inf
      removed = True

  return list


'''
Calculates a vector of slack times for a given 
problem. 
@param V the base problem
@returns a vector of slack times
'''
def lstf(V, min_start, occupancy, deadline):
  slack_time = [None for i in V[0]]
  for i in range(0, len(V)):
    for j in range(0, len(V[i])):
      if V[i][j] != None:
        li, ls = V[i][j]
        st = ls - li
        # if(slack_time[j] == None or st < slack_time[j]):
        if(slack_time[j] == None or st > slack_time[j]):
            slack_time[j] = st
  #return slack_time
  
  # most slack time first, least slack time 
  # will be consumed first
  list = []

  removed = True
  while removed:
    largest = -inf
    idx = -inf

    removed = False

    for i in range(0, len(slack_time)):
      if slack_time[i] > largest:
        largest = slack_time[i]
        idx = i
        
    if largest != -inf:
      list.append(idx)
      slack_time[idx] = -inf
      removed = True

  return list

'''
Calculates a weighted vector. Higher values represent
  packets in more critical links. 
@param V the base problem
@returns a vector of slack times
'''
def mcpf(solution_space, min_start, O, deadline):
  # find the total load of each link
  load = [0 for x in O]

  # for each packet, sum the usage of 
  # that packet for each link
  for l in range(0, len(O)):
    acc = 0
    for p in range(0, len(O[0])):
      if(O[l][p] != None):
        #acc += O[l][p]      #usage
        acc += 1
    load[l] = acc

  # for each packet, sum their total occupancy,
  # multiplied by the weight of each link
  crit = [0 for x in O[0]]
  for p in range(0, len(crit)):
    acc = 0
    for l in range(0, len(O)):
      if(O[l][p] != None):
        acc += O[l][p] * load[l]
    crit[p] = acc
  
  return crit