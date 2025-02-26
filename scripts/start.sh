#!/bin/bash

# Error handling
set -e

# Validate required environment variables
for var in "USER" "PASSWORD" "VNC_PASSWORD" "HOME" "DISPLAY"; do
    if [ -z "${!var}" ]; then
        echo "Error: Required environment variable $var is not set"
        exit 1
    fi
done

# Initial cleanup
echo "Cleaning up existing processes..."
pkill Xtightvnc 2>/dev/null || true
pkill websockify 2>/dev/null || true
pkill xrdp 2>/dev/null || true

# Start SSH
echo "Starting SSH server..."
service ssh start

# Setup directories
echo "Setting up user directories..."
mkdir -p ${HOME}/.vnc
chown -R ${USER}:${USER} ${HOME}

# First-time configuration
if [ ! -f ${HOME}/.vnc/configured ]; then
    echo "First initialization, configuring VNC and SSH..."
    
    # Set VNC password
    if [ ! -f ${HOME}/.vnc/passwd ]; then
        echo ${VNC_PASSWORD} | vncpasswd -f > ${HOME}/.vnc/passwd
        chmod 600 ${HOME}/.vnc/passwd
        chown ${USER}:${USER} ${HOME}/.vnc/passwd
    fi
    
    # Configure VNC startup
    if [ ! -f ${HOME}/.vnc/xstartup ]; then
        echo "#!/bin/bash\nxrdb \$HOME/.Xresources\nstartxfce4 &" > ${HOME}/.vnc/xstartup
        chmod +x ${HOME}/.vnc/xstartup
        chown ${USER}:${USER} ${HOME}/.vnc/xstartup
    fi
    
    touch ${HOME}/.vnc/configured
    echo "First-time configuration completed!"
fi

# Start VNC server
echo "Starting VNC server..."
if ! pgrep -x "Xtightvnc" > /dev/null; then
    su - ${USER} -c "tightvncserver ${DISPLAY} -geometry 1280x800 -depth 24 -dpi 96 -alwaysshared"
else
    echo "VNC server already running."
fi

# Start NoVNC
echo "Starting NoVNC..."
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &

# Start XRDP
echo "Starting XRDP..."
service xrdp start

# Display connection information
echo "==============================================="
echo "CONTAINER READY"
echo "-----------------------------------------------"
echo "NoVNC: http://localhost:6080/vnc.html?autoconnect=true&resize=scale&quality=9"
echo "VNC: localhost:5901"
echo "RDP: localhost:3389"
echo "SSH: localhost:22"
echo "==============================================="

# Keep container running and monitor services
while true; do
    sleep 30
    # Restart services if they die
    pgrep -x "Xtightvnc" >/dev/null || su - ${USER} -c "tightvncserver ${DISPLAY} -geometry 1280x800 -depth 24 -dpi 96 -alwaysshared"
    pgrep -x "xrdp" >/dev/null || service xrdp start
done