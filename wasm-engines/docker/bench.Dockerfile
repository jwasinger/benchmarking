FROM jwasinger/life:1.0 as life
FROM jwasinger/wabt:1.0 as wabt
# FROM jwasinger/wagon as wagon
FROM jwasinger/wasm3:1.0 as wasm3
FROM jwasinger/ssvm:1.0 as ssvm
FROM jwasinger/wasmtime:1.0 as wasmtime
FROM jwasinger/wamr:1.0 as wamr
FROM jwasinger/wagon:1.0 as wagon

# wavm broken
FROM jwasinger/wavm:1.0 as wavm

FROM jwasinger/fizzy:1.0 as fizzy
FROM jwasinger/asmble:1.0 as asmble
FROM jwasinger/wasmi:1.0 as wasmi
FROM jwasinger/bench-base:1.0
FROM jwasinger/wagon:1.0

# install rust
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain stable -y && . $HOME/.cargo/env
ENV PATH=/root/.cargo/bin:$PATH

## install dependencies for standalone wasm prep
RUN pip3 install jinja2 pandas click durationpy

# Install Clang 8 (needed for life -polymerase)
# RUN apt update && apt install -y clang-8 lldb-8 lld-8

# Install clang 10 (for life -polymerase)
RUN echo "deb http://apt.llvm.org/eoan/ llvm-toolchain-eoan-10 main\
deb-src http://apt.llvm.org/eoan/ llvm-toolchain-eoan-10 main" >> /etc/apt/sources.list

RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - && apt update -y && apt install -y clang-10 lldb-10 lld-10

RUN ln -s /usr/bin/clang++-10  /usr/bin/clang++
RUN ln -s /usr/bin/clang-10  /usr/bin/clang

ENV CC=clang
ENV CXX=clang++

ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# rust wasm32 target for compiling wasm
RUN rustup target add wasm32-unknown-unknown

RUN mkdir -p /benchmark_results_data && mkdir /engines

# install node for v8 benchmarks

RUN curl -fsSLO --compressed https://nodejs.org/dist/v11.10.0/node-v11.10.0-linux-x64.tar.gz && \
  tar -xvf node-v11.10.0-linux-x64.tar.gz -C /usr/local/ --strip-components=1 --no-same-owner

RUN apt install -y openjdk-8-jre

# wasm engine binaries
COPY --from=wabt /wabt/build/wasm-interp /engines/wabt/wasm-interp
COPY --from=fizzy /fizzy/build/bin/fizzy-bench /engines/fizzy/fizzy-bench
COPY --from=wasmi /wasmi/target/release/examples/invoke /engines/wasmi/invoke

COPY --from=wavm  /wavm-build/ /engines/wavm
RUN cd /engines/wavm/Lib && find . -name "*.so" -exec cp -prv '{}' '/usr/lib' ';'

COPY --from=life  /life/life /engines/life/life
COPY --from=wasm3 /wasm3/build/wasm3 /engines/wasm3/wasm3
COPY --from=wasmtime /wasmtime/target/release/wasmtime /engines/wasmtime/wasmtime
COPY --from=ssvm /SSVM/build/tools/ssvm/ssvm /engines/ssvm/ssvm

COPY --from=wamr /wasm-micro-runtime/product-mini/platforms/linux/build_interp/iwasm /engines/wamr/iwasm
COPY --from=wamr /wasm-micro-runtime/wamr-compiler/build/wamrc /engines/wamr/wamrc
COPY --from=asmble /asmble/ /engines/asmble/
COPY --from=wagon /wagon/cmd/wasm-run/wasm-run /engines/wagon/wasm-run

# copy benchmarking scripts
RUN mkdir /benchrunner
COPY project /benchrunner/project
COPY main.py /benchrunner
COPY wamr_aot.sh /engines/wamr/
COPY fizzy.sh /engines/fizzy/

RUN mkdir /engines/node && ln -s /usr/local/bin/node /engines/node/node 

# copy scripts to generate standalone wasm modules
RUN mkdir /benchprep

WORKDIR /benchprep

CMD /bin/bash