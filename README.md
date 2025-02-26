# Kali Linux Desktop in Docker

A Docker container running Kali Linux with XFCE desktop environment, accessible via VNC, NoVNC, or RDP.

## Quick Start

1. Clone the repository
2. Adjust settings in `.env` file if needed
3. Start the container:
```bash
docker compose up --force-recreate --build
```

## Access Methods

- NoVNC: `http://localhost:6080/vnc.html?autoconnect=true&resize=scale&quality=9`
- VNC: `localhost:5901`
- SSH: `localhost:22`

P.S. The container can be hosted and used as a server, in which case the IP may vary.

## Default Credentials

- Username: `kali`
- Password: `kali`
- VNC Password: `kali`

## Cleanup

To remove the container and volumes (WARNING: this will delete the entire persistent system):
```bash
docker compose down --volumes
```
