FROM jwasinger/llvm-10

# install rust
RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain 1.42.0 -y && . $HOME/.cargo/env
ENV PATH=/root/.cargo/bin:$PATH

RUN git clone --single-branch --branch bench-times https://github.com/cdetrio/wasmtime.git
RUN cd wasmtime && cargo build --release
