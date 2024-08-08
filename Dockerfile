# Use Ubuntu as the base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    make \
    git \
    zlib1g-dev \
    libssl-dev \
    gperf \
    cmake \
    clang-14 \
    libc++-14-dev \
    libc++abi-14-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone the main repository and initialize submodules
RUN git clone https://github.com/tdlib/telegram-bot-api.git && \
    cd telegram-bot-api && \
    git submodule update --init --recursive

# Build telegram-bot-api
RUN cd telegram-bot-api && \
    mkdir build && \
    cd build && \
    CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-14 CXX=/usr/bin/clang++-14 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake --build . --target install && \
    cd ../.. && \
    ls -l telegram-bot-api/bin/telegram-bot-api*

# Set the working directory to where the binary is located
WORKDIR /app/telegram-bot-api/bin

# Create a shell script to run telegram-bot-api with environment variables
RUN echo '#!/bin/sh\n\
exec ./telegram-bot-api --api-id="$APP_ID" --api-hash="$APP_HASH" --http-ip-address="0.0.0.0" --http-port="$PORT"  "$@"' > entrypoint.sh && \
    chmod +x entrypoint.sh

# Use ENTRYPOINT with the shell script and CMD for additional arguments
ENTRYPOINT ["/app/telegram-bot-api/bin/entrypoint.sh"]
CMD []