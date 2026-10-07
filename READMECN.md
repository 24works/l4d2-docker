# Left 4 Dead 2 Docker Server

这是一个基于 [HoshinoRei/l4d2server-docker](https://github.com/HoshinoRei/l4d2server-docker) 的项目，用于通过 Docker 快速部署《求生之路 2》专用服务器。镜像会自动从 SteamCMD 拉取最新版服务端，并同时推送到 **Docker Hub** 与 **GitHub Container Registry (GHCR)**。

---

## 📦 镜像地址

| Registry | 镜像 |
| --- | --- |
| Docker Hub | `24workers/l4d2server:latest` |
| Docker Hub（日期标签） | `24workers/l4d2server:YYMMDD`，例如 `24workers/l4d2server:261007` |
| GHCR | `ghcr.io/24works/l4d2-docker:latest` |
| GHCR（日期标签） | `ghcr.io/24works/l4d2-docker:YYMMDD` |

> `latest` 永远指向最新一次构建；日期标签用于回滚到某个特定日期的版本。

---

## 📂 项目结构

| 文件 / 目录 | 说明 |
| --- | --- |
| `host.txt` | 显示在服务器右上角的信息 |
| `motd.txt` | 服务器主页显示的每日消息 |
| `addons/` | 插件目录（SourceMod、MetaMod 等） |
| `cfg/server.cfg` | 服务器主配置文件，其中 `hostname` 决定服务器名称 |
| `Dockerfile` | 镜像构建文件 |
| `docker-compose.yml` | Docker Compose 编排文件 |

---

## 🌐 Language / 语言

- **English**（本文件）
- [中文](READMECN.md)

---

## 🚀 快速开始

### 前置条件

- 已安装 **Docker CE**
- 已安装 **Docker Compose**（可选，但推荐）

### 方式一：使用 Docker Compose（推荐）

1. 克隆仓库：

   ```sh
   git clone https://github.com/yourusername/l4d2-docker-dev.git
   cd l4d2-docker-dev
   ```

2. 启动服务器：

   ```sh
   docker compose up -d
   ```

3. 查看日志：

   ```sh
   docker compose logs -f
   ```

4. 停止服务器：

   ```sh
   docker compose down
   ```

### 方式二：使用 Docker CLI

1. 克隆仓库：

   ```sh
   git clone https://github.com/yourusername/l4d2-docker-dev.git
   cd l4d2-docker-dev
   ```

2. 构建镜像：

   ```sh
   docker build -t l4d2server .
   ```

3. 运行容器：

   ```sh
   docker run -d \
     --name l4d2server \
     -p 27015:27015 \
     -p 27015:27015/udp \
     -v "$(pwd)/addons:/home/steam/l4d2server/left4dead2/addons" \
     -v "$(pwd)/cfg/server.cfg:/home/steam/l4d2server/left4dead2/cfg/server.cfg:ro" \
     -v "$(pwd)/host.txt:/home/steam/l4d2server/left4dead2/host.txt:ro" \
     -v "$(pwd)/motd.txt:/home/steam/l4d2server/left4dead2/motd.txt:ro" \
     24workers/l4d2server:latest \
     -secure +exec server.cfg -port 27015 -tickrate 100
   ```

4. 停止并删除容器：

   ```sh
   docker stop l4d2server
   docker rm l4d2server
   ```

### 方式三：直接拉取官方镜像

如果你不想自己构建，可以直接拉取已发布的镜像：

```sh
# 从 Docker Hub 拉取
docker pull 24workers/l4d2server:latest

# 或从 GHCR 拉取
docker pull ghcr.io/24works/l4d2-docker:latest
```

---

## ⚙️ 配置说明

### 端口

| 端口 | 协议 | 用途 |
| --- | --- | --- |
| `27015` | TCP | 服务器查询 / RCON |
| `27015` | UDP | 游戏主端口 |

### 挂载卷（Volume）

| 容器内路径 | 说明 |
| --- | --- |
| `/home/steam/l4d2server/left4dead2/addons` | 插件目录 |
| `/home/steam/l4d2server/left4dead2/cfg/server.cfg` | 服务器配置 |
| `/home/steam/l4d2server/left4dead2/host.txt` | 服务器右上角信息 |
| `/home/steam/l4d2server/left4dead2/motd.txt` | 每日消息 |

### 启动参数

镜像的默认启动参数为：

```
-secure +exec server.cfg +map c1m1_hotel -port 27015
```

可以在 `docker run` 命令末尾覆盖，例如修改地图或 tickrate：

```sh
... 24workers/l4d2server:latest \
    -secure +exec server.cfg +map c2m1_highway -port 27015 -tickrate 100
```

---

## 🔄 更新服务器版本

服务端内容由 SteamCMD 在镜像构建时拉取。项目包含一个 GitHub Actions workflow，可手动触发重建：

1. 进入仓库的 **Actions** 页面。
2. 选择 **One-Click Build and Push Docker Image**。
3. 点击 **Run workflow**，选择分支后运行。

构建完成后会同时推送 `latest` 与 `YYMMDD` 两个标签。本地更新只需：

```sh
docker compose pull
docker compose up -d
```

如果日期标签版本更稳定、想回滚：

```sh
# 修改 docker-compose.yml 中的镜像 tag 为例如 24workers/l4d2server:261007
docker compose up -d
```

---

## 🧰 常见问题

- **服务器启动后玩家搜不到？**  
  确认防火墙 / 安全组已放行 `27015 TCP` 与 `27015 UDP`。

- **想更换地图？**  
  修改 `docker-compose.yml` 的 `command` 参数中的 `+map` 字段，或直接覆盖 `docker run` 命令末尾的参数。

- **addons 里的插件没生效？**  
  确认插件依赖已放入 `addons/` 并通过 SourceMod 加载；修改后执行 `docker restart l4d2server`。

---

## 🙏 致谢

- 原始项目：[HoshinoRei/l4d2server-docker](https://github.com/HoshinoRei/l4d2server-docker)
- Valve 官方服务端：SteamCMD App ID `222860`

---

## 📄 License

本仓库仅供个人学习与自建服务器使用，游戏内容版权归 Valve 所有。