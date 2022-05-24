from numpy import empty
from terminal import error, info

'''
Copies given vector and returns a new 
vector containing the same elements as 
the entered vector.
@param m the input vector
@returns a vector containing the same elements of m
'''
def vcopy(m):
  v = []
  for i in m:
    v.append(i) 
  return v   

'''
Copies a bi-dimensional matrix and returns a 
new matrix containing the same elements as the 
entered matrix.
@param m the input matrix
@returns a matrix containing the same elements of m
'''
def mcopy(m):
  v = []
  for i in m:
    v.append(vcopy(i))
  return v

'''
Checks whether two ranges overleap.
@param ra range a, the first range 
@param rb range b, the second range
@returns True if the ranger overleap, otherwise False
'''
def overleap(ra, rb):
  mina, maxa = ra
  minb, maxb = rb

  return (mina < minb and maxb > minb) or \
         (minb < mina and maxa > mina)


'''
Checks whether a given partial solution has a valid
solution within it. 
@param V the partial solution
@returns True if a solution is still feasible, False otherwise
'''
def check(V):
  for i in range(0, len(V)):
    for j in range(0, len(V[0]) - 1):
      if(V[i][j] != -1):
        rangea = V[i][j]
        for k in range(j + 1, len(V[0])):
          if(V[i][k] != -1):
            rangeb = V[i][k]
            if overleap(rangea, rangeb):
              return False
  return True

'''
Calculates a vector of slack times for a given 
problem. 
@param V the base problem
@returns a vector of slack times
'''
def lstf(V):
  slack_time = [-1 for i in V[0]]
  for i in range(0, len(V)):
    for j in range(0, len(V[i])):
      if V[i][j] != -1:
        li, ls = V[i][j]
        st = ls - li
        if(slack_time[j] == -1 or st < slack_time[j]):
            slack_time[j] = st
  return slack_time

'''
Finds the next node to be processed given a list 
of available nodes and a max heuristic
@param avp the list of available nodes 
@param h the heuristic values 
@returns The index of the next node to be processed,
  -1 otherwise. 
'''
def nextnode(avp, h):
  idx = -1
  max = -1
  for i in range(0, len(avp)):
    if (avp[i] and h[i] > max):
      max = h[i]
      idx = i
  return idx

'''
Heuristic search. 
@param M minimum release time values 
@param O occupancy values
@param D deadline values 
@param V problem instance
@param avp a list of nodes in the problem
@param h a heuristic vector 
'''
def hsearch(M, O, D, V, avp, h, depth=0):

  # print current solution node
  for i in V:
    print(i)
  print()
  print("depth =", depth)

  # if(depth == 2):
  #   exit(0)

  # verify whether we reach a leaf node 
  num_avp = avp.count(False) == len(avp)

  # if node reached, then evaluate current
  # solution. If this is a suitable solution, 
  # return it. Otherwise keep going.
  if(num_avp):
    checkres = check(V)
    if(checkres):
      return V

  # collect least slack time for the heuristic
  nnode = nextnode(avp, h)
  packet_range = (0,0)
  navp = vcopy(avp)
  navp[nnode] = False
  
  # acquire packet solution range
  for i in range(0, len(V)):
    if(V[i][nnode] != -1):
      packet_range = V[i][nnode]
      break
  
  # iterate through the range
  min, max = packet_range
  print("current_range:", min, max)
  for k in range(min, max):
    vv = mcopy(V)

    #replace value for that package
    for i in range(0, len(V)):
      if(vv[i][nnode] != -1):
        vv[i][nnode] = (k, k + O[i][nnode])

    # Check consistency. If branch has a possible
    # solution, keep searching

    res = check(vv)
    if(res):
      r = hsearch(M, O, D, vv, navp, h, depth+1)

  return None



def search2(min_start, occupancy, deadline):
  # find virtual occupancy

  for i in occupancy:
    print(i)

  vocc = []
  for i in range(0, len(occupancy)):
    row = []
    for j in range(0, len(occupancy[i])):
      cell = occupancy[i][j]
      if(cell == -1):
        row.append(cell)
      else:
        row.append((min_start[i][j], deadline[i][j] - occupancy[i][j]))
    vocc.append(row)

  avp = [True for i in vocc[0]]
  h = lstf(vocc)
  res = hsearch(min_start, occupancy, deadline, vocc, avp, h)