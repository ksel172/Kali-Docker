FROM kalilinux/kali-rolling

ARG DEBIAN_FRONTEND
ARG USER
ARG PASSWORD
ARG VNC_PASSWORD
ARG HOME
ARG DISPLAY

# Install base packages
RUN apt update && apt install -y \
    sudo \
    openssh-server \
    kali-desktop-xfce \
    xfce4 \
    xterm \
    dbus-x11 \
    novnc \
    websockify \
    net-tools \
    x11-xserver-utils \
    tigervnc-standalone-server \
    tigervnc-common \
    python3 \
    curl \
    procps \
    tightvncserver \
    xrdp \
    iptables \
    systemd-sysv \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Configure user
RUN useradd -m -s /bin/bash ${USER} && \
    echo "${USER}:${PASSWORD}" | chpasswd && \
    usermod -aG sudo ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Configure VNC
RUN mkdir -p ${HOME}/.vnc && \
    echo ${VNC_PASSWORD} | vncpasswd -f > ${HOME}/.vnc/passwd && \
    chmod 600 ${HOME}/.vnc/passwd && \
    chown -R ${USER}:${USER} ${HOME}/.vnc

# Configure VNC startup
RUN echo "#!/bin/bash\nxrdb \$HOME/.Xresources\nstartxfce4 &" > ${HOME}/.vnc/xstartup && \
    chmod +x ${HOME}/.vnc/xstartup && \
    chown ${USER}:${USER} ${HOME}/.vnc/xstartup

# Configure XRDP
RUN sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/xserverbpp=24/xserverbpp=24/g' /etc/xrdp/xrdp.ini && \
    echo "[Xvnc]\nname=Xvnc\nlib=libvnc.so\nargs=-geometry 1280x800 -depth 24 -dpi 96 :1" > /etc/xrdp/xrdp_vncserver.ini && \
    cat /etc/xrdp/xrdp_vncserver.ini >> /etc/xrdp/xrdp.ini

# Configure NoVNC
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# TODO: Make it auto update upon entry

EXPOSE 22 6080 3389

CMD ["/scripts/start.sh"]