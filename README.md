# Left 4 Dead 2 Docker Server

A Docker setup for running a **Left 4 Dead 2** dedicated server, based on [HoshinoRei/l4d2server-docker](https://github.com/HoshinoRei/l4d2server-docker). The image automatically pulls the latest server build via SteamCMD and is pushed to both **Docker Hub** and **GitHub Container Registry (GHCR)**.

---

## 📦 Image Locations

| Registry | Image |
| --- | --- |
| Docker Hub | `24workers/l4d2server:latest` |
| Docker Hub (date tag) | `24workers/l4d2server:YYMMDD`, e.g. `24workers/l4d2server:261007` |
| GHCR | `ghcr.io/24works/l4d2-docker:latest` |
| GHCR (date tag) | `ghcr.io/24works/l4d2-docker:YYMMDD` |

> `latest` always points to the most recent build; date tags let you roll back to a specific day's build.

---

## 📂 Project Structure

| File / Directory | Description |
| --- | --- |
| `host.txt` | Text shown in the top-right corner of the server |
| `motd.txt` | Message of the day displayed on the server's main page |
| `addons/` | Plugin directory (SourceMod, MetaMod, etc.) |
| `cfg/server.cfg` | Main server configuration; `hostname` sets the server name |
| `Dockerfile` | Image build definition |
| `docker-compose.yml` | Docker Compose orchestration file |

---

## 🌐 Language / 语言

- **English** (this file)
- [中文](READMECN.md)

---

## 🚀 Getting Started

### Prerequisites

- **Docker CE** installed
- **Docker Compose** installed (optional but recommended)

### Option 1: Docker Compose (Recommended)

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/l4d2-docker-dev.git
   cd l4d2-docker-dev
   ```

2. Start the server:

   ```sh
   docker compose up -d
   ```

3. View logs:

   ```sh
   docker compose logs -f
   ```

4. Stop the server:

   ```sh
   docker compose down
   ```

### Option 2: Docker CLI

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/l4d2-docker-dev.git
   cd l4d2-docker-dev
   ```

2. Build the image:

   ```sh
   docker build -t l4d2server .
   ```

3. Run the container:

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

4. Stop and remove the container:

   ```sh
   docker stop l4d2server
   docker rm l4d2server
   ```

### Option 3: Pull the Prebuilt Image

If you don't want to build it yourself, you can pull the published image directly:

```sh
# From Docker Hub
docker pull 24workers/l4d2server:latest

# Or from GHCR
docker pull ghcr.io/24works/l4d2-docker:latest
```

---

## ⚙️ Configuration

### Ports

| Port | Protocol | Purpose |
| --- | --- | --- |
| `27015` | TCP | Server query / RCON |
| `27015` | UDP | Main game port |

### Volumes

| Container Path | Description |
| --- | --- |
| `/home/steam/l4d2server/left4dead2/addons` | Plugin directory |
| `/home/steam/l4d2server/left4dead2/cfg/server.cfg` | Server configuration |
| `/home/steam/l4d2server/left4dead2/host.txt` | Top-right corner info |
| `/home/steam/l4d2server/left4dead2/motd.txt` | Message of the day |

### Startup Command

The image starts with the following default arguments:

```
-secure +exec server.cfg +map c1m1_hotel -port 27015
```

Override them at the end of the `docker run` command, for example to change the map or tickrate:

```sh
... 24workers/l4d2server:latest \
    -secure +exec server.cfg +map c2m1_highway -port 27015 -tickrate 100
```

---

## 🔄 Updating the Server

The server content is fetched by SteamCMD at image build time. This repository ships with a GitHub Actions workflow that can be triggered manually:

1. Go to the repository's **Actions** tab.
2. Select **One-Click Build and Push Docker Image**.
3. Click **Run workflow**, pick a branch, and run.

Once the build finishes, both `latest` and `YYMMDD` tags are pushed. To update locally:

```sh
docker compose pull
docker compose up -d
```

To roll back to a specific date tag:

```sh
# Change the image tag in docker-compose.yml to, e.g., 24workers/l4d2server:261007
docker compose up -d
```

---

## 🧰 Troubleshooting

- **Server is up but not appearing in the server browser?**  
  Make sure your firewall or security group allows `27015 TCP` and `27015 UDP`.

- **Want to change the map?**  
  Edit the `+map` value in the `command` section of `docker-compose.yml`, or override the arguments at the end of the `docker run` command.

- **Plugins in `addons/` aren't working?**  
  Verify that dependencies are placed under `addons/` and loaded by SourceMod; restart with `docker restart l4d2server` after changes.

---

## 🙏 Credits

- Original project: [HoshinoRei/l4d2server-docker](https://github.com/HoshinoRei/l4d2server-docker)
- Valve dedicated server: SteamCMD App ID `222860`

---

## 📄 License

This repository is intended for personal learning and self-hosted servers only. All game content is copyright of Valve.