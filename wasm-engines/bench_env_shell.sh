#! /bin/bash

docker run --privileged \
	-v $(pwd)/project:/benchrunner/projects \
	-v $(pwd)/main.py:/benchrunner/main.py \
	-v $(pwd)/benchnativerust_prepwasm.py:/benchprep/benchnativerust_prepwasm.py \
	-v $(pwd)/wasm-engines/wasmfiles:/wasmfiles \
	-v $(pwd)/benchmark_results_data:/benchmark_results_data \
	-v $(pwd)/nanodurationpy.py:/benchprep/nanodurationpy.py \
	-v $(pwd)/rust-code:/benchprep/rust-code \
	-v $(pwd)/inputvectors:/benchprep/inputvectors \
	-v $(pwd)/benchmeteredstandalone.sh:/benchprep/benchmeteredstandalone.sh \
	-v $(pwd)/bench_wasm_and_native.sh:/benchprep/bench_wasm_and_native.sh \
--security-opt seccomp=$(pwd)/dockerseccompprofile.json -it wasm-engines /bin/bash
