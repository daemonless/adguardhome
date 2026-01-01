# adguardhome

Network-wide ads & trackers blocking DNS server, running natively on FreeBSD.

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AGH_USER` | User to run as (`bsd` or `root`) | `bsd` |
| `TZ` | Timezone for the container | `UTC` |
| `S6_LOG_ENABLE` | Enable/Disable file logging | `1` |
| `S6_LOG_MAX_SIZE` | Max size per log file (bytes) | `1048576` |
| `S6_LOG_MAX_FILES` | Number of rotated log files to keep | `10` |

## Deployment Options

AdGuard Home needs to bind to port 53 for DNS. On FreeBSD, this requires root privileges. This image supports multiple deployment scenarios:

### Option 1: VLAN/Macvlan with Dedicated IP (run as root)

Container gets its own IP address, binds directly to port 53.

```bash
podman run -d --name adguardhome \
  -e AGH_USER=root \
  --network vlan4 --ip 192.168.4.25 --mac-address 0e:04:00:00:00:19 \
  -v /containers/adguardhome:/config \
  ghcr.io/daemonless/adguardhome:latest
```

### Option 2: Bridge Network with Port Mapping (run as bsd)

Container runs unprivileged, uses port mapping for DNS.

```bash
podman run -d --name adguardhome \
  --network podman \
  -p 53:5353/udp -p 53:5353/tcp -p 3000:3000 \
  -v /containers/adguardhome:/config \
  ghcr.io/daemonless/adguardhome:latest
```

Configure AdGuard Home to listen on port 5353 during the setup wizard.

### Option 3: Host Network (run as bsd)

Container shares host's network stack, configure high port in wizard.

```bash
podman run -d --name adguardhome \
  --network host \
  -v /containers/adguardhome:/config \
  ghcr.io/daemonless/adguardhome:latest
```

Configure AdGuard Home to listen on port 5353 during the setup wizard.

## First Run

1. Access the setup wizard at `http://<container-ip>:3000`
2. Configure DNS listen address and port
3. Configure web interface port
4. Set admin username and password
5. Complete the wizard

## Logging

This image uses `s6-log` for internal log rotation.
- **System Logs**: Stored at `/config/logs/daemonless/adguardhome/`
- **Application Logs**: AdGuard Home logs in `/config/work/`
- **Podman Logs**: Output is mirrored to the console, so `podman logs` still works.

## Tags

| Tag | Source | Description |
|-----|--------|-------------|
| `:latest` | [Upstream Releases](https://github.com/AdguardTeam/AdGuardHome/releases) | Latest upstream release |
| `:pkg` | FreeBSD Quarterly | FreeBSD package (quarterly branch) |
| `:pkg-latest` | FreeBSD Latest | FreeBSD package (latest branch) |

## Volumes

| Path | Description |
|------|-------------|
| `/config` | Configuration and data directory |
| `/config/conf` | AdGuardHome.yaml configuration |
| `/config/work` | Working directory (query logs, filters) |

## Ports

| Port | Protocol | Description |
|------|----------|-------------|
| 53 | TCP/UDP | DNS queries |
| 67-68 | UDP | DHCP server |
| 80 | TCP | Web UI (HTTP) |
| 443 | TCP/UDP | Web UI (HTTPS) / DNS-over-HTTPS |
| 853 | TCP/UDP | DNS-over-TLS / DNS-over-QUIC |
| 3000 | TCP | Setup wizard (initial config) |
| 5443 | TCP/UDP | DNSCrypt |
| 6060 | TCP | Debug/profiling |

## Multi-Instance Sync

For redundant DNS with synchronized configuration, use [adguardhome-sync](https://github.com/bakito/adguardhome-sync).

## Notes

- **User:** Configurable via `AGH_USER` (default: `bsd`, set to `root` for port 53)
- **Base:** Built on `ghcr.io/daemonless/base` (FreeBSD)
- **First Run:** Setup wizard configures DNS and web ports

## Links

- [Website](https://adguard.com/adguard-home.html)
- [Documentation](https://github.com/AdguardTeam/AdGuardHome/wiki)
- [FreshPorts](https://www.freshports.org/www/adguardhome/)
