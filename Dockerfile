# Use Ubuntu as the base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    make \
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

# Copy the local telegram-bot-api files
COPY . .

# Build telegram-bot-api
RUN mkdir build && \
    cd build && \
    CXXFLAGS="-stdlib=libc++" CC=/usr/bin/clang-14 CXX=/usr/bin/clang++-14 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=.. .. && \
    cmake --build . --target install && \
    cd .. && \
    ls -l bin/telegram-bot-api*

# Set the working directory to where the binary is located
WORKDIR /app/bin

# Create a shell script to run telegram-bot-api with environment variables
RUN echo '#!/bin/sh\n\
exec ./telegram-bot-api --api-id="$APP_ID" --api-hash="$HASH" "$@"' > entrypoint.sh && \
    chmod +x entrypoint.sh

# Use ENTRYPOINT with the shell script and CMD for additional arguments
ENTRYPOINT ["/app/bin/entrypoint.sh"]
CMD []