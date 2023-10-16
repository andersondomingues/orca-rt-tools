rm -rf apps/*.dot apps/*.clustered apps/*.png
python3.11 -m gcm apps/sample_graph.txt 4 MIN_CPU_USAGE
