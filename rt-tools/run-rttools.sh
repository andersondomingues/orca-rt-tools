#!/bin/bash

# FORMAT:
# python3.11 rttools/__main__.py <app> <map> <arch> [<freq>] [<step>] [<tries>]

# SHI et al. 2010
#python3.11 rttools/__main__.py application/SHI2010.csv mappings/SHI2010-ONTO-hermes4x4.map architecture/hermes-4x4.gml 2000000 2000 500

# STR2RTS-CFAR
python3.11 rttools/__main__.py application/STR2RTS-CFAR.csv mappings/STR2RTS-CFAR-ONTO-hermes2x2.map architecture/hermes-2x2.gml 1000000 1 2000 False


