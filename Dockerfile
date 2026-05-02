# Ubuntu 24.04 (host platform).
FROM ubuntu:24.04

COPY scripts/docker/00_bootstrap_ubuntu24.sh /tmp/bootstrap.sh
RUN bash /tmp/bootstrap.sh && rm -rf /var/lib/apt/lists/* && rm /tmp/bootstrap.sh

WORKDIR /workspace

CMD ["/bin/bash"]
