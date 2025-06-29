FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    vim \
    net-tools \
    iputils-ping \
    git \
    htop \
    sudo \
    tmux \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Add user 'sol' with password '123'
RUN useradd -m -s /bin/bash sol && echo 'sol:123' | chpasswd && usermod -aG sudo sol

# Install Solana CLI as sol user
USER sol
WORKDIR /home/sol

# Install Solana CLI
RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

# Set PATH environment variable with explicit path
ENV PATH="/home/sol/.local/share/solana/install/active_release/bin:${PATH}"

# Also add to shell profile for interactive sessions
RUN echo 'export PATH="/home/sol/.local/share/solana/install/active_release/bin:$PATH"' >> /home/sol/.bashrc

# Keep the container running indefinitely
CMD ["sleep", "infinity"]

# 5uotPsUYuyVzC2qxg97r1LUk8bXsMF8rYLRY9h5fbicookJoFNxKbpHtNwfRGrJjdSUBHyayScHWHh6A7RJWBuMj