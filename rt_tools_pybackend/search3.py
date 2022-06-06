from numpy import append, empty
from terminal import debug, error, info, warn
from heuristics import lstf, mbul, mcpf
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
@param h a heuristic vector 
'''
def hsearch(M, O, D, space, partial, h, packets, links, depth, step):

  hsearch.entered += 1

  # verify whether we reach a leaf node.
  # if node reached, then evaluate current
  # solution. If this is a suitable solution, 
  # return it. Otherwise keep going.
  if len(h) == 0:
    return partial

  # Select next node based on the heuristic. 
  # Ex. get the lesser slack time
  nnode = h.pop()

  # print current solution node
  used_links = []
  for l in range(0, len(O)):
    if(O[l][nnode] != None):
      used_links.append(links[l])

  debug("depth:" + str(depth) + " " + packets[depth] + " | " + " ".join(used_links))
  #warn(h)

  # acquire packet solution range
  packet_range = (0,0) 
  for i in range(0, len(space)):
    if(space[i][nnode] != None):
      packet_range = space[i][nnode]
      break
  
  # iterate through the range
  min, max = packet_range
  #print("current_range:", min, max, step, k)
  for k in range(min, max, int((max - min)/100) ):
  #for k in range(min, max, step):

    # replace value for that package
    for i in range(0, len(space)):
      if(space[i][nnode] != None):
        partial[i][nnode] = k

    # Check consistency. If branch has a possible
    # solution, keep searching
    if(check_consistency(partial, O, nnode)):
      res = hsearch(M, O, D, space, partial, h, packets, links, depth + 1, step)
      if(res != None):
        return res
    else:
      hsearch.ignored += 1

  # rewrite values back to the partial solution before returning
  # replace value for that package
  for i in range(0, len(space)):
    if(space[i][nnode] != None):
      partial[i][nnode] = None

  h.append(nnode)
  return None

'''
Self-counting!
'''
hsearch.entered = 0
hsearch.ignored = 0

def search3(min_start, occupancy, deadline, heuristic, packets, links, step):
  
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

  # Heuristic
  h = heuristic(solution_space, min_start, occupancy, deadline)

  # call search at node zero
  return (hsearch(min_start, occupancy, deadline, solution_space, partial_solution, h, packets, links, 0, step),
    hsearch.entered, hsearch.ignored)
