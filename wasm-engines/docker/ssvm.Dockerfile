FROM jwasinger/llvm:10

RUN apt update -y && apt install -y libboost-all-dev && git clone https://github.com/ewasm-benchmarking/SSVM.git --single-branch --branch bench
RUN cd SSVM && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF .. && make
