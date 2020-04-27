#! /usr/bin/env bash

set -e

if $life;
then
	echo "installing life"
# clang-8 needed for life polymerase
	apt install -y clang-8 lldb-8 lld-8

	ln -s /usr/bin/clang-8 /usr/bin/clang && \
		ln -s /usr/bin/clang++-8 /usr/bin/clang++

#install life
	git clone --single-branch --branch bench-times https://github.com/cdetrio/life
	cd life && go mod vendor
	cd life && go build

fi

if $wasmi;
then
	echo "installing wasmi"
	git clone --single-branch --branch bench-time https://github.com/cdetrio/wasmi.git --recursive
	cd wasmi && cargo test --release
fi

if $wavm;
then
    echo "installing wavm"
# old gcc needed for wavm
	apt install -y gcc-7
	apt install -y g++-7
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 10
	update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 10

	git clone --single-branch --branch bench-compile-time https://github.com/cdetrio/WAVM
	mkdir wavm-build
	cd wavm-build && cmake -G Ninja ../WAVM -DCMAKE_BUILD_TYPE=RelWithDebInfo
	cd wavm-build && ninja
fi

if $wasmtime;
then
    echo "installing wasmtime"
	rustup default nightly-2019-01-15 # <- TODO: wat
	git clone --single-branch --branch bench-times https://github.com/cdetrio/wasmtime.git
	cd wasmtime && cargo build --release

fi

if $wabt;
then
    echo "installing wabt"
    git clone --recursive --single-branch --branch bench-times https://github.com/cdetrio/wabt.git
    mkdir wabt/build && cd wabt/build && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF .. && make
fi

# wamr (interpreter, aot, jit)

if $wamr;
then
    echo "installing wamr"
	git clone https://github.com/hugo-dc/wasm-micro-runtime.git --single-branch --branch benchmark
	cd wasm-micro-runtime && git pull origin benchmark
## Build LLVM
	cd wasm-micro-runtime/product-mini/platforms/linux && ./build_llvm.sh
## Build JIT
	cd wasm-micro-runtime/product-mini/platforms/linux && ./build_jit.sh
## Build Interpreter
	cd wasm-micro-runtime/product-mini/platforms/linux && mkdir build_interp && cd build_interp && cmake -DWAMR_BUILD_INTERP=1 .. -DCMAKE_BUILD_TYPE=Release .. && make                                             
## Build Compiler
	cd wasm-micro-runtime/wamr-compiler && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make                      
fi

if $wasm3;
then
    echo "installing wasm3"
	git clone https://github.com/hugo-dc/wasm3.git --single-branch --branch benchmark
	cd wasm3 && mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make
fi

if $fizzy;
then
    echo "installing fizzy"
    update-alternatives --remove-all gcc
    update-alternatives --remove-all g++
    apt install -y gcc-9
    apt install -y g++-9

    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 1
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 1

    git clone https://github.com/wasmx/fizzy.git --single-branch --branch master
    cd fizzy && mkdir build && cd build && cmake -DFIZZY_TESTING=ON .. && cmake --build .
fi

if $v8_13;
then
    echo "installing v8"
	echo "not implemented"
fi
