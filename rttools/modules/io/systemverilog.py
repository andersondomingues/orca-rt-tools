from os.path import exists
from os import remove

def exportPackets(expDir, lws, prob, lwf):

  packets = []
  base_addr = "'h0"
  ddma_addr = "'h12345"

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
      file =  open(expDir + '/' + str(current_source) + '.sv', 'w')

      file.write('module ddma_driver_tb{0} #()(\n'.format(str(current_source)))
      file.write('  input logic clock,\n')
      file.write('  input logic reset,\n')
      file.write('  interface_router_port.ROUTER router_if,\n')
      file.write('  interface_memory.DUT mem_if,\n')
      file.write('  interface_ddma.TCD ddma_if\n')
      file.write(');\n\n\n')

      file.write('integer counter = 0;\n')
      file.write('always @(posedge clock) begin\n')
      file.write('  counter <= counter + 1;\n') 
      file.write('end\n\n\n')

      file.write('initial begin\n\n')
      file.write('  router_if.clock_tx = clock;\n')
      file.write('  router_if.data_o = counter;\n')

      delay = 0
      for i in range(0, len(packets_to_process)):
        
        e = packets_to_process[i]


        # wait until the packet release time to configure another packet
        file.write('  #{0};  // wait {1} cycles\n\n'.format(str(delay * 2), str(delay)))

        file.write('  // source_node:  {0}\n'.format(str(e['source_node'])))
        file.write('  // target_node:  {0}\n'.format(str(e['target_node'])))
        file.write('  // source_xy:    {0}\n'.format(str(e['source_xy'])))
        file.write('  // target_xy:    {0}\n'.format(str(e['target_xy'])))
        file.write('  // data_size:    {0}\n'.format(str(e['data_size'])))
        file.write('  // release_time: {0}\n'.format(str(e['release_time'])))

        # write header flit
        file.write('  #2;\n')
        file.write('  mem_if.enable_in = 1;\n')
        file.write('  mem_if.wb_in = 1;\n')
        file.write('  mem_if.data_in = ({x} << 16) & {y};  // header flit\n'.format(
          x = e['target_xy']['X'],
          y = e['target_xy']['Y']
        ))
        file.write('  mem_if.addr_in = {0};\n\n'.format(base_addr))

        # write size flit
        file.write('  #2;\n')
        file.write('  mem_if.enable_in = 1;\n')
        file.write('  mem_if.wb_in = 1;\n')
        file.write('  mem_if.data_in = {0};  // {1} bytes, size flit\n'.format(
          str(int(e['data_size'] / 4)),
          str(int(e['data_size']))
        ))
        file.write("  mem_if.addr_in = {0} + 'h4;\n\n".format(base_addr))

        # configure ddma
        file.write('  #2;\n')
        file.write("  ddma_if.addr_in = 'h0;\n")
        file.write('  ddma_if.nbytes = {0};\n'.format(int(e['data_size'])))
        file.write('  ddma_if.cmd_in = 1;\n\n')
        file.write('  mem_if.wb_in = 0;  // lock memory write\n\n\n')

        # lock memory access
        file.write('  #2;\n')    # !! must acknowledge ddma protocol here
      
        # configure current packet
        # ddma_addr


        # configure next packet when there's no more flits 
        # to be transmitted. 
        # num_words =  data_size / 4 
        # numn_cycles = num_words * 2
        delay = int(e['data_size'] / 2)


      file.write('end\n\n')
      file.write('endmodule\n\n')
      file.close()

      # clear the list 
      packets_to_process = []

      # update current source node
      current_source = p['source_node']
      
    # otherwise, append current packet to the source node list 
    else: 
      packets_to_process.append(p)
      

  print('total packets:', len(packets))
