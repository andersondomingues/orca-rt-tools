def evaluate(min_start, occupancy, deadline, release, hp):
  for i in range(0, len(min_start) -1):
    for j in range(0, len(min_start[i]) -1):
      if min_start[i][j] != -1:
        # release_time must be greater or equals to the min_start
        # UNNECESSARY
        if min_start[i][j] >= release[i][j]:
          return False
        # packet must be transmited before its deadline
        # UNNECESSARY
        if deadline[i][j] < release[i][j] + occupancy[i][j]:
          return False

# % definition of overleap predicate (same as in job shop)
# predicate nonoverlap(
#   var int:b1, % begin of span 1
#   var int:e1, % duration of span 1
#   var int:b2, % begin of span 2
#   var int:e2  % duration of span 2
# ) = b1 + e1 < b2 \/ b2 + e2 < b1;

  # TODO: non-overleap
  for i in range(0, len(min_start) -1):
    for j in range(0, len(min_start[i]) -1):
      for k in range(0, k):
        if not (
          release[i][j] + occupancy[i][j] < release[i][k] or
          release[i][k] + occupancy[i][k] < release[i][j]
        ):
          return False

  return True

def vcopy(m):
  v = []
  for i in m:
    v.append(i) 
  return v   

def mcopy(m):
  v = []
  for i in m:
    v.append(vcopy(i))
  return v

def xprint(m):
  for i in m:
    print(i)
  print()

def search(min_start, occupancy, deadline, release, hp, depth):

  partial_solution = mcopy(release)
 
  if evaluate(min_start, occupancy, deadline, partial_solution, hp):
    xprint(partial_solution)
    return partial_solution

  for j in range(0, len(min_start[0]) - 1):
    for i in range(0, len(min_start) -1):
    
      if partial_solution[i][j] != -1:

        # time limit to release the packet is equals to 
        # its deadline, minus its occupancy
        if partial_solution[i][j] + occupancy[i][j] + 1 < deadline[i][j]:
          partial_solution[i][j] = partial_solution[i][j] + 1
          # print(partial_solution[i][j], occupancy[i][j], deadline[i][j])

          # increment one cell before retrying
          res = search(partial_solution, occupancy, deadline, partial_solution, hp, depth + 1)
          if res:
            return res
  return False