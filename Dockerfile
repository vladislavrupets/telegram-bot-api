# Use Ubuntu as the base image
FROM ubuntu:22.04 as builder

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Use ARG for Railway environment variables
ARG RAILWAY_ENVIRONMENT
ARG PORT

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
    cmake --build . --target install

# Start a new stage for the final image
FROM ubuntu:22.04

# Copy the built binary from the builder stage
COPY --from=builder /app/telegram-bot-api/bin/telegram-bot-api /app/telegram-bot-api

# Set the working directory
WORKDIR /app

# Create a shell script to run telegram-bot-api with environment variables
RUN echo '#!/bin/sh\n\
PORT=${PORT:-8081}\n\
exec ./telegram-bot-api --api-id="$APP_ID" --api-hash="$APP_HASH" --http-port="$PORT" "$@"' > entrypoint.sh && \
    chmod +x entrypoint.sh

# Use ENTRYPOINT with the shell script and CMD for additional arguments
ENTRYPOINT ["/app/entrypoint.sh"]
CMD []