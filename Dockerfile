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
    nginx \
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

# Set up Nginx configuration
RUN echo "events { worker_connections 1024; } \n\
http { \n\
    server { \n\
        listen 80; \n\
        server_name \$RAILWAY_PRIVATE_DOMAIN; \n\
        location / { \n\
            proxy_pass http://localhost:8081; \n\
            proxy_set_header Host \$host; \n\
            proxy_set_header X-Real-IP \$remote_addr; \n\
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for; \n\
            proxy_set_header X-Forwarded-Proto \$scheme; \n\
        } \n\
    } \n\
}" > /etc/nginx/nginx.conf

# Create a shell script to run both telegram-bot-api and Nginx
RUN echo '#!/bin/sh\n\
nginx &\n\
/app/telegram-bot-api/bin/telegram-bot-api --api-id="$APP_ID" --api-hash="$HASH" --local --http-port=8081 --dir=/var/lib/telegram-bot-api --temp-dir=/tmp/telegram-bot-api --log=/var/log/telegram-bot-api.log "$@"' > /app/entrypoint.sh && \
    chmod +x /app/entrypoint.sh

# Use ENTRYPOINT with the shell script
ENTRYPOINT ["/app/entrypoint.sh"]