# ========================================================
# Stage: Builder
# ========================================================
FROM debian AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Set Go version variable
ARG GO_VERSION=1.24.2

# Install base tools and download Go from the official site
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget \
      ca-certificates \
      build-essential \
      gcc \
      curl \
      
      systemctl \
      socat \
      unzip && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Go
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Configure Go environment
ENV PATH="/usr/local/go/bin:${PATH}" \
    CGO_ENABLED=1 \
    CGO_CFLAGS="-D_LARGEFILE64_SOURCE"

WORKDIR /app

# Download Go dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build the application
COPY . .
RUN go build -ldflags "-w -s" -o build/x-ui main.go

# Run the DockerInit.sh script
RUN chmod +x ./DockerInit.sh && \
    ./DockerInit.sh

# ========================================================
# Stage: Final Image of 3x-ui (debian-based)
# ========================================================
FROM debian

ENV TZ=Asia/Tehran \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      tzdata \
      curl \
      systemctl \
      fail2ban \
      bash && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/build/ /app/
COPY --from=builder /app/DockerEntrypoint.sh /app/
COPY --from=builder /app/x-ui.sh /usr/bin/x-ui

# Configure fail2ban
RUN rm -f /etc/fail2ban/jail.d/alpine-ssh.conf && \
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local && \
    sed -i 's/^\[ssh\]$/&\nenabled = false/' /etc/fail2ban/jail.local && \
    sed -i 's/^\[sshd\]$/&\nenabled = false/' /etc/fail2ban/jail.local && \
    sed -i 's/#allowipv6 = auto/allowipv6 = auto/' /etc/fail2ban/fail2ban.conf && \
    chmod +x /app/DockerEntrypoint.sh /app/x-ui /usr/bin/x-ui

VOLUME [ "/etc/x-ui" ]

ENTRYPOINT [ "/app/DockerEntrypoint.sh" ]
CMD [ "./x-ui" ]

