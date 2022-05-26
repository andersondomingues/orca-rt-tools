from numpy import empty
from terminal import debug, error, info
import os


'''
Prints a matrix, row by row.
'''
def mprint(m):
  for i in m:
    print(i)

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

  return not(maxa < minb or maxb < mina)

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
  slack_time = [None for i in V[0]]
  for i in range(0, len(V)):
    for j in range(0, len(V[i])):
      if V[i][j] != None:
        li, ls = V[i][j]
        st = ls - li
        if(slack_time[j] == None or st < slack_time[j]):
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
  idx = None
  max = None
  for i in range(0, len(avp)):
    if (avp[i] and (idx == None or h[i] < max)):
      max = h[i]
      idx = i
  return idx

'''
Checks whether some packets conflits with
other packets in the model. 
'''
def check_consistency(V, O, idx):

  # acquire range for package at V[idx]
  rangea = (0,0)
  for i in range(0, len(V)-1):
    if(V[i][idx] != None):
      rangea = (V[i][idx], V[i][idx] + O[i][idx])

  # for each link in the model
  for i in range(0, len(V)-1):

    # ignore row if current packet doesnt use that link
    if(V[i][idx] != None):

      # for each packet in that link, find if it 
      # overleaps current packet
      for j in range(0, len(V[0])-1):
        if(j != idx and V[i][j] != None): # avoid comparing to itself
          rangeb = (V[i][j], V[i][j] + O[i][j])

          if(overleap(rangea, rangeb)):
            return False
  return True

'''
Heuristic search. 
@param M minimum release time values 
@param O occupancy values
@param D deadline values 
@param V problem instance
@param avp a list of nodes in the problem
@param h a heuristic vector 
'''
def hsearch(M, O, D, space, partial, avp, h, depth=0):

  hsearch.entered += 1

  # print current solution node
  #os.system('clear')
  debug("depth:" + str(depth))
  mprint(partial)
  print("--")
  mprint(space)

  # verify whether we reach a leaf node.
  # if node reached, then evaluate current
  # solution. If this is a suitable solution, 
  # return it. Otherwise keep going.
  if(avp.count(False) == len(avp)):
    return partial

  # Select next node based on the heuristic. 
  # Ex. get the lesser slack time
  nnode = nextnode(avp, h)

  # Copy remaining nodes list and disable current
  # node from selection
  navp = vcopy(avp)
  navp[nnode] = False

  # acquire packet solution range
  packet_range = (0,0) 
  for i in range(0, len(space)):
    if(space[i][nnode] != None):
      packet_range = space[i][nnode]
      break
  
  # iterate through the range
  min, max = packet_range
  #print("current_range:", min, max)
  for k in range(min, max):

    # copy current solution and replace range
    # by the values of current iteration
    vv = mcopy(partial)

    # replace value for that package
    for i in range(0, len(space)):
      if(space[i][nnode] != None):
        vv[i][nnode] = k

    # Check consistency. If branch has a possible
    # solution, keep searching
    if(check_consistency(vv, O, nnode)):
      res = hsearch(M, O, D, space, vv, navp, h, depth + 1)
      if(res != None):
        return res
    else:
      hsearch.ignored += 1

  return None


'''
Self-counting!
'''
hsearch.entered = 0
hsearch.ignored = 0

def search3(min_start, occupancy, deadline):
  
  # Initial solution has no packets placed yet.
  # Rationally: select packet with the highest
  # value for the given heuristic. Place the 
  # selected packet and then select another one.
  partial_solution = [[None for x in occupancy[0]] for y in occupancy]

  # Generate ranges of solution here. At this 
  # point, we proceed as Minizinc, using intervalar
  # arithmetics. Sparse matrix notation takes '-1' as 
  solution_space = mcopy(occupancy)
  for i in range(0, len(solution_space)):
    for j in range(0, len(solution_space[i])):
      cell = solution_space[i][j]
      if(cell != None):
        solution_space[i][j] = (min_start[i][j], deadline[i][j] - occupancy[i][j])

  # List of packets fixed in the solution so far
  avp = [True for i in occupancy[0]]

  # Heuristic
  h = lstf(solution_space)

  # call search at node zero
  return (hsearch(min_start, occupancy, deadline, solution_space, partial_solution, avp, h), hsearch.entered, hsearch.ignored)
