# vintage-story-server

## Description
A simple image to run Vintage Story using docker. The container will download the server files with the given version number.

The image also supports running unstable versions of the game using the `CHANNEL` envrionment. The value must match either `stable` or `unstable`.

## Image
The image and it's tags are found here: https://hub.docker.com/repository/docker/neebz/vintage-story-server/general

Version `2026.05.10-1` and later have been updated to dotnet 10 to follow the game version >= 1.22. If you want to play < 1.21 you should stay on tag `2025.07.28-1`.
Note that this version requires the Docker Run `user` to be 1000.
Version `2026.05.10-1` is updated to mount both download and server files to game files with a bind mount to ensure user privileges work as intended.

Version `2025.07.28-1` and later have been updated to dotnet 8 to follow the game version >= 1.21.
If you want to play < 1.21 you should stay on tag `2025.04.14-1`. Note that this version does NOT support the `CHANNEL` environment variable.

## Setup
The setup requires a directory for the game files and server files (which includes saves files, config files and logs) to be defined before starting the container, as well as a user with write access to this directory. That user's UID and GID must be set in the user parameter for the container. The mounts should target `/app/server_files` and `/app/game_files`.

### Running with compose
```
services:
  vintage_story:
    image: neebz/vintage-story-server:latest
    ports:
      - "42420:42420/tcp"
      - "42420:42420/udp"
    volumes:
      - path-on-host/server_files:/app/server_files
      - path-on-host/game_files:/app/game_files
    environment:
      - VERSION=1.22.2
      - CHANNEL=stable
    user: "1000:1000"
```

### Running with docker run
```
docker run -d \
  --name vintage_story \
  -p 42420:42420/tcp \
  -p 42420:42420/udp \
  -v /path-on-host/server_files:/app/server_files \
  -v /path-on-host/game_files:/app/game_files \
  -e VERSION=1.22.2 \
  -e CHANNEL=stable \
  --user 1000:1000 \
  neebz/vintage-story-server:latest
```

## Editing the config
Configuration of the server takes place within the `app/data` mount in `serverconfig.json`.

Configs are explained in the official Vintage Story documentation here https://wiki.vintagestory.at/Server_Config.

To get started I recommend setting the following configs:
* `ServerName`
* `ServerDescription`
* `WelcomeMessage`
* `Password`
* `WorldConfig.SaveFileLocation` if you want to use an existing save or simply name the save that the server will generate
* `WhitelistMode` set to `off` if you want to rely only on password protection
