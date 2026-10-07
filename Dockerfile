FROM debian:12-slim

# 缓存击穿开关：值变化则之后的 RUN 层都重新执行
# 由 workflow 传入，例如 20261007153045
ARG CACHEBUST=0
# 构建日期，例如 261007，写入 LABEL 便于识别版本
ARG L4D2_VERSION=dev

LABEL org.opencontainers.image.source=https://github.com/HoshinoRei/l4d2server-docker
LABEL L4D2_VERSION=${L4D2_VERSION}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LANGUAGE=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        lib32gcc-s1 \
        lib32stdc++6 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    adduser --home /home/steam --disabled-password --shell /bin/bash --gecos "user for running steam" --quiet steam

USER steam
WORKDIR /home/steam

RUN wget -O steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    tar -xzf steamcmd_linux.tar.gz && \
    rm -f steamcmd_linux.tar.gz

# steamcmd 自更新（也会因为 CACHEBUST 变化而重跑）
RUN echo "cachebust=${CACHEBUST}" && \
    ./steamcmd.sh +login anonymous +quit

# Windows 平台依赖（L4D2 的 Windows 资源会顺带拉到 Linux 目录里）
RUN ./steamcmd.sh \
        +force_install_dir /home/steam/l4d2server \
        +@sSteamCmdForcePlatformType windows \
        +login anonymous \
        +app_update 222860 validate \
        +quit

# Linux 平台服务端本体
RUN ./steamcmd.sh \
        +force_install_dir /home/steam/l4d2server \
        +@sSteamCmdForcePlatformType linux \
        +login anonymous \
        +app_update 222860 validate \
        +quit

RUN rm -f /home/steam/l4d2server/left4dead2/host.txt \
          /home/steam/l4d2server/left4dead2/motd.txt

EXPOSE 27015 27015/udp

VOLUME ["/home/steam/l4d2server/left4dead2/addons", \
        "/home/steam/l4d2server/left4dead2/cfg/server.cfg", \
        "/home/steam/l4d2server/left4dead2/motd.txt", \
        "/home/steam/l4d2server/left4dead2/host.txt"]

ENTRYPOINT ["/home/steam/l4d2server/srcds_run", "-game left4dead2"]
CMD ["-secure", "+exec server.cfg", "+map c1m1_hotel", "-port 27015"]