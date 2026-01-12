ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG UPSTREAM_URL="https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest"
ARG UPSTREAM_JQ=".tag_name"
ARG HEALTHCHECK_ENDPOINT="http://localhost:3000"

ENV HEALTHCHECK_URL="${HEALTHCHECK_ENDPOINT}"

# --- Metadata (Injected by Generator) ---
LABEL org.opencontainers.image.title="AdGuard Home" \
      org.opencontainers.image.description="Network-wide ads & trackers blocking DNS server on FreeBSD." \
      org.opencontainers.image.source="https://github.com/daemonless/adguardhome" \
      org.opencontainers.image.url="https://adguard.com/adguard-home.html" \
      org.opencontainers.image.documentation="https://github.com/AdguardTeam/AdGuardHome/wiki" \
      org.opencontainers.image.licenses="GPL-3.0-only" \
      org.opencontainers.image.vendor="daemonless" \
      org.opencontainers.image.authors="daemonless" \
      io.daemonless.category="Network" \
      io.daemonless.port="53" \
      io.daemonless.volumes="/opt/adguardhome/conf,/opt/adguardhome/work" \
      io.daemonless.arch="${FREEBSD_ARCH}" \
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

# --- Expose (Injected by Generator) ---
EXPOSE 53 53 67 68 80 443 443 784 853 853 3000 5443 5443 6060 8853

# --- Volumes (Injected by Generator) ---
VOLUME /opt/adguardhome/conf /opt/adguardhome/work