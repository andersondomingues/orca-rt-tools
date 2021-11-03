# using RT_TOOLS to generate minizinc input
# python3 rt_tools/__main__.py pkt applications/Synthetic-Flow-C.gml mappings/Synthetic-Flow-C-ONTO-hermes4x4.map architecture/hermes-4x4.gml

# using RT_TOOLS to generate pkt-sim input
python3 rt_tools/__main__.py vhdl applications/Synthetic-Flow-D.gml mappings/Synthetic-Flow-D-ONTO-hermes4x4.map architecture/hermes-4x4.gml results/Synthetic-Flow-D.txt
