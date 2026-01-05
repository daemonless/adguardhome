ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG UPSTREAM_URL="https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest"
ARG UPSTREAM_JQ=".tag_name"
ARG HEALTHCHECK_ENDPOINT="http://localhost:3000"

ENV HEALTHCHECK_URL="${HEALTHCHECK_ENDPOINT}"

LABEL org.opencontainers.image.title="AdGuard Home" \
    org.opencontainers.image.description="Network-wide ads & trackers blocking DNS server on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/adguardhome" \
    org.opencontainers.image.url="https://adguard.com/adguard-home.html" \
    org.opencontainers.image.documentation="https://github.com/AdguardTeam/AdGuardHome/wiki" \
    org.opencontainers.image.licenses="GPL-3.0-only" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="3000" \
    io.daemonless.ports="53,67,68,80,443,784,853,3000,5443,6060,8853" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.category="Network" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.upstream-jq="${UPSTREAM_JQ}" \
    io.daemonless.healthcheck-url="${HEALTHCHECK_ENDPOINT}"

# Download and install AdGuard Home from upstream releases
# Use /opt/adguardhome paths to match official Docker image
RUN mkdir -p /opt/adguardhome/conf /opt/adguardhome/work /app && \
    VERSION=$(fetch -qo - "${UPSTREAM_URL}" | jq -r '.tag_name') && \
    echo "Installing AdGuard Home ${VERSION}" && \
    fetch -qo - "https://github.com/AdguardTeam/AdGuardHome/releases/download/${VERSION}/AdGuardHome_freebsd_${FREEBSD_ARCH}.tar.gz" | \
    tar xzf - -C /tmp && \
    mv /tmp/AdGuardHome/AdGuardHome /opt/adguardhome/ && \
    chmod +x /opt/adguardhome/AdGuardHome && \
    echo "${VERSION}" > /app/version && \
    chown -R bsd:bsd /opt/adguardhome && \
    rm -rf /tmp/AdGuardHome

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/adguardhome/run /etc/cont-init.d/* 2>/dev/null || true

# Match official Docker image ports
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 443/udp 784/udp 853/tcp 853/udp 3000/tcp 5443/tcp 5443/udp 6060/tcp 8853/udp

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work"]
