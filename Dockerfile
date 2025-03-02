# Write a docker file for github self-hosted runner with Debian 12 slim
FROM debian:12-slim

# Install GitHub Actions Runner 
ARG RUNNER_VERSION="2.322.0"
ARG RUNNER_CHECKSUM="b13b784808359f31bc79b08a191f5f83757852957dd8fe3dbfcc38202ccf5768"

# Working directory
WORKDIR /runner

# Copy entrypoint script and make it executable
COPY entrypoint.sh .

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  sudo \
  curl \
  unzip \
  iputils-ping \
  net-tools \
  libicu72 \
  && apt-get clean \
  && apt-get autoremove \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd runner && useradd -g runner runner \
  && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  && echo "${RUNNER_CHECKSUM}  actions-runner.tar.gz" | sha256sum -c - \
  && tar xzf ./actions-runner.tar.gz \
  && rm actions-runner.tar.gz \ 
  && chmod +x /runner/entrypoint.sh \
  && chown -R runner:runner /runner \ 
  && sudo /runner/bin/installdependencies.sh 

# Switch to runner user
USER runner

# Configure the runner
ENTRYPOINT ["/bin/bash", "/runner/entrypoint.sh"]