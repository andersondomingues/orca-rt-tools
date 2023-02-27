def exportPackets(expDir, lws, prob, lwf):
    packets = []
    base_addr = "'h0"
    # ddma_addr = "'h12345"

    STARTING_DELAY = 100

    # for all links, get packets whose first output link if L-*
    for l in range(0, len(lws)):
        source, target, data = prob["links"][l]  # link data

        if source == "L":  # only links from output ports
            for p in range(0, len(lws[0])):
                if lws[l][p] is None:  # packet whose the output port is in the path
                    # print(prob['packets'][p])
                    #   name, flow, source (task name), target (task name),
                    #   min_start, abs_deadline, datasize, path, net_time
                    packets.append(
                        {
                            "name": prob["packets"][p]["name"],
                            "source_node": target,  # which is actually the source
                            "target_node": prob["packets"][p]["path"][-1]["edge"][
                                "source"
                            ][
                                "node"
                            ],  # destination
                            "source_xy": prob["packets"][p]["path"][0]["edge"][
                                "target"
                            ][
                                "data"
                            ],  # source
                            "target_xy": prob["packets"][p]["path"][-1]["edge"][
                                "source"
                            ][
                                "data"
                            ],  # destination
                            "data_size": prob["packets"][p][
                                "datasize"
                            ],  # number of bytes
                            "release_time": lws[l][p],  # computed release time
                        }
                    )

    def index(arr):
        return arr["source_node"]

    # sort array by link name
    packets.sort(key=index)

    current_source = None
    packets_to_process = []

    # sorting criterion
    def reltime(p):
        return p["release_time"]

    filename = expDir + "/mockup.sv"
    file = open(filename, "w")

    file.write("`timescale 1ns/10ps\n\n")

    file.write("module ddma_driver_tb #(MEMORY_BUS_WIDTH, FLIT_WIDTH, ADDRESS)(\n")
    file.write("  input logic clock,\n")
    file.write("  input logic reset,\n")
    file.write("  interface_memory.DUT mem_if,\n")
    file.write("  interface_ddma.TCD ddma_if\n")
    file.write(");\n\n\n")

    file.write("integer counter = 0;\n")
    file.write("always @(posedge clock) begin\n")
    file.write("  counter <= counter + 1;\n")
    file.write("end\n\n\n")

    file.write("initial begin\n\n")
    file.write("  // delay to handle initialization offset\n")
    # file.write('  #{0}\n\n'.format(STARTING_DELAY))
    file.write("  mem_if.enable_in = 1;\n")
    file.write("  ddma_if.addr_in = 0;\n")
    file.write("  ddma_if.nbytes_in = 0;\n")
    file.write("  ddma_if.cmd_in = 0;\n")

    for p in packets:
        # make sure that first node won't be skipped
        if current_source is None:
            current_source = p["source_node"]

        # if the source has changed, or we reach the lst node,
        # sort the list, save file, clear the list
        if p["source_node"] != current_source or p == packets[-1]:
            # add condition to this packet to run
            file.write(
                "  // ============== PE NUM {0} ============== \n".format(
                    current_source
                )
            )
            file.write("  if (ADDRESS == {0}) begin\n\n".format(current_source))

            # sort the list
            packets_to_process.sort(key=reltime)

            cycles = 0
            for i in range(0, len(packets_to_process)):
                e = packets_to_process[i]

                file.write("    // pkt name:     {0}\n".format(str(e["name"])))
                file.write("    // source_node:  {0}\n".format(str(e["source_node"])))
                file.write("    // target_node:  {0}\n".format(str(e["target_node"])))
                file.write("    // source_xy:    {0}\n".format(str(e["source_xy"])))
                file.write("    // target_xy:    {0}\n".format(str(e["target_xy"])))
                file.write("    // data_size:    {0}\n".format(str(e["data_size"])))
                file.write("    // release_time: {0}\n".format(str(e["release_time"])))

                # write header flit
                file.write("    mem_if.wb_in = 1;\n")
                file.write(
                    "    mem_if.data_in = ({x} << (FLIT_WIDTH / 4)) | {y};\n".format(
                        x=e["target_xy"]["X"], y=e["target_xy"]["Y"]
                    )
                )
                file.write("    mem_if.addr_in = {0};\n".format(base_addr))
                file.write("    #1;\n\n")
                cycles += 1

                num_flits: int = e["data_size"] / 4

                # write size flit
                file.write("    mem_if.wb_in = 1;\n")
                file.write(
                    "    mem_if.data_in = {0};  // {1} bytes, size flit\n".format(
                        str(num_flits), str(int(e["data_size"]))
                    )
                )
                file.write("    mem_if.addr_in = {0} + 'h1;\n".format(base_addr))
                file.write("    #1;\n\n")
                cycles += 1

                file.write("    mem_if.wb_in = 0;  // lock memory write\n\n\n")
                # file.write('    mem_if.data_in = \'z;\n')
                # file.write('    mem_if.addr_in = \'z;\n')

                # wait the difference between the current
                # cycle count and the target release time
                file.write(
                    "    #{0}; // skipt to {1}\n".format(
                        str((e["release_time"] + STARTING_DELAY) - cycles),
                        str(e["release_time"]),
                    )
                )

                cycles = e["release_time"] + STARTING_DELAY

                # configure ddma
                file.write("    ddma_if.addr_in = 'h0;\n")

                # +2 header overhead
                file.write("    ddma_if.nbytes_in = {0};\n".format(num_flits + 2))
                file.write("    ddma_if.cmd_in = 1;\n")
                file.write("    #1;\n\n")

                file.write("    ddma_if.addr_in = 0;\n")
                file.write("    ddma_if.nbytes_in = 0;\n")
                file.write("    ddma_if.cmd_in = 0; \n")
                # file.write('    #1;\n\n')

                cycles += 1

                # !! must acknowledge ddma protocol here
                # lock memory access
                # configure current packet
                # ddma_addr

            file.write("  end\n\n")  # close if for this packets

            filemeta = open(expDir + "/meta_" + current_source + ".txt", "w")
            for pmeta in packets_to_process:
                filemeta.write(pmeta["name"] + ": " + str(pmeta) + "\n")
            filemeta.close()

            # clear the list
            packets_to_process = []

            # update current source node
            current_source = p["source_node"]

        # otherwise, append current packet to the source node list
        else:
            packets_to_process.append(p)

    file.write("\n\nend\n\n")
    file.write("endmodule\n\n")

    file.close()
