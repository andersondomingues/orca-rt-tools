from os.path import exists
from os import remove

def exportPackets(expDir, lws, prob, lwf):

  packets = []

  # for all links, get packets whose first output link if L-*
  for l in range(0, len(lws)):

    source, target, data = prob['links'][l]  # link data
    
    if(source == 'L'):  # only links from output ports

      for p in range(0, len(lws[0])): 

        if lws[l][p] != None:  # packet whose the output port is in the path
          packets.append({
            'source_node': target,  # which is actually the source 
            'target_node': prob['packets'][p]['path'][-1]['edge']['source']['node'],  # destination
            'source_xy': prob['packets'][p]['path'][0]['edge']['target']['data'],   # source            
            'target_xy': prob['packets'][p]['path'][-1]['edge']['source']['data'],  # destination
            'data_size': prob['packets'][p]['datasize'],  # number of bytes
            'release_time' : lws[l][p]  # computed release time
          })

  def index(arr):
    return arr['source_node']

  # sort array by link name
  packets.sort(key=index)

  # destroi existing packet files
  for i in range(0, len(prob['links'])):
    filename = expDir + '/' + str(i) + '.txt'
    if exists(filename):
      remove(filename)

  current_source = None
  packets_to_process = []

  # sorting criterion
  def reltime(p):
    return p['release_time']

  for p in packets:

    # make sure that first node won't be skipped
    if current_source == None:
      current_source = p['source_node']

    # if the source has changed, sort the list, save file, clear the list
    elif p['source_node'] != current_source:

      # sort the list 
      packets_to_process.sort(key=reltime)

      # save file 
      file =  open(str(current_source) + '.txt', 'w')

      for e in packets_to_process:
        file.write(str(e))

      file.close()

      # clear the list 
      packets_to_process = []

      # update current source node
      current_source = p['source_node']
      
    # otherwise, append current packet to the source node list 
    else: 
      packets_to_process.append(p)
      

  print('total packets:', len(packets))
