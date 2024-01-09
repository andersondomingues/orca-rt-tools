all:
	python3.11 -m gcm apps/sample_graph.txt 4 MIN_CPU_USAGE

# generate random graphs
rgg:
	python3.11 -m rgg 100 2000 20000 0.01 2000 20000 apps/20_001.txt
	python3.11 -m rgg 100 2000 20000 0.02 2000 20000 apps/20_002.txt
	python3.11 -m rgg 100 2000 20000 0.03 2000 20000 apps/20_003.txt
	python3.11 -m rgg 100 2000 20000 0.04 2000 20000 apps/20_004.txt
	python3.11 -m rgg 100 2000 20000 0.05 2000 20000 apps/20_005.txt
	python3.11 -m rgg 100 2000 20000 0.06 2000 20000 apps/20_006.txt
	python3.11 -m rgg 100 2000 20000 0.07 2000 20000 apps/20_007.txt
	python3.11 -m rgg 100 2000 20000 0.08 2000 20000 apps/20_008.txt
	python3.11 -m rgg 100 2000 20000 0.09 2000 20000 apps/20_009.txt
	python3.11 -m rgg 100 2000 20000 0.1 2000 20000 apps/20_010.txt
	python3.11 -m rgg 100 2000 20000 0.2 2000 20000 apps/20_020.txt
	python3.11 -m rgg 100 2000 20000 0.3 2000 20000 apps/20_030.txt
	python3.11 -m rgg 100 2000 20000 0.4 2000 20000 apps/20_040.txt
	python3.11 -m rgg 100 2000 20000 0.5 2000 20000 apps/20_050.txt
	python3.11 -m rgg 100 2000 20000 0.6 2000 20000 apps/20_060.txt


# collect random graphs metrics
gde:
	python3.11 -m gde apps/20_001.txt
	python3.11 -m gde apps/20_002.txt
	python3.11 -m gde apps/20_003.txt
	python3.11 -m gde apps/20_004.txt
	python3.11 -m gde apps/20_005.txt
	python3.11 -m gde apps/20_006.txt
	python3.11 -m gde apps/20_007.txt
	python3.11 -m gde apps/20_008.txt
	python3.11 -m gde apps/20_009.txt
	python3.11 -m gde apps/20_010.txt
	python3.11 -m gde apps/20_020.txt
	python3.11 -m gde apps/20_030.txt
	python3.11 -m gde apps/20_040.txt
	python3.11 -m gde apps/20_050.txt
	python3.11 -m gde apps/20_060.txt

  

sgv:
	python3.11 -m gcm apps/var-gdensity/20_001.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_002.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_003.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_004.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_005.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_006.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_007.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_008.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_009.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_010.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_020.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_030.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_040.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_050.txt 4 MIN_COMM
	python3.11 -m gcm apps/var-gdensity/20_060.txt 4 MIN_COMM

# collect random graphs metrics (MIN-COMM)
gde-clustered:
	python3.11 -m gde apps/10_10.clustered.mpmc
	python3.11 -m gde apps/10_20.clustered.mpmc
	python3.11 -m gde apps/10_30.clustered.mpmc
	python3.11 -m gde apps/10_40.clustered.mpmc
	python3.11 -m gde apps/10_50.clustered.mpmc
	python3.11 -m gde apps/10_60.clustered.mpmc
	python3.11 -m gde apps/10_70.clustered.mpmc
	python3.11 -m gde apps/10_80.clustered.mpmc
	python3.11 -m gde apps/10_90.clustered.mpmc
	python3.11 -m gde apps/10_100.clustered.mpmc
	python3.11 -m gde apps/10_200.clustered.mpmc
	python3.11 -m gde apps/10_300.clustered.mpmc
	python3.11 -m gde apps/10_400.clustered.mpmc
	python3.11 -m gde apps/10_500.clustered.mpmc
	python3.11 -m gde apps/10_600.clustered.mpmc
	python3.11 -m gde apps/10_700.clustered.mpmc
	python3.11 -m gde apps/10_800.clustered.mpmc
	python3.11 -m gde apps/10_900.clustered.mpmc
	python3.11 -m gde apps/10_1000.clustered.mpmc

clean:
	rm -rf apps/*.dot apps/*.clustered apps/*.png apps/*.trace* apps/*.svg


# FORMAT:
format:
	echo "python3.11 rttools/__main__.py <app> <map> <arch> [<freq>] [<step>] [<tries>]"

# SHI et al. 2010
shi:
	python3.11 rttools/__main__.py application/SHI2010.csv mappings/SHI2010-ONTO-hermes4x4.map architecture/hermes-4x4.gml 2000000 2000 500

# STR2RTS-CFAR
rttools:
	python3.11 rttools/__main__.py application/STR2RTS-CFAR.csv mappings/STR2RTS-CFAR-ONTO-hermes2x2.map architecture/hermes-2x2.gml 1000000 1 2000 False





.PHONY: all rgg clean rgg_gen gde gde-min-comm gcm