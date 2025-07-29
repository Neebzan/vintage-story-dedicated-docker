# vintage-story-dedicated-docker

## Description
A simple image to run Vintage Story using docker. The container will download the server files with the given version number.

The image also supports running unstable versions of the game using the `CHANNEL` envrionment. The value must match either `stable` or `unstable`.

## Image
The image and it's tags are found here: https://hub.docker.com/repository/docker/neebz/vintage-story-server/general

Version `2025.07.28-1` and later have been updated to dotnet 8 to follow the game version >= 1.21.
If you want to play < 1.21 you should stay on tag `2025.04.14-1`. Note that this version does NOT support the `CHANNEL` environment variable.

## Setup
The setup requires a directory for the saves file, config files and logs to be defined, as well as a user with write access to this directory. That user's UID and GID must be set in the user parameter for the container. The mount should target `app/data`.

### Running with compose
```
services:
  vintage_story:
    image: neebz/vintage-story-server:latest
    ports:
      - "42420:42420/tcp"
      - "42420:42420/udp"
    volumes:
      - /path/on/host:/app/data
      - vintage-story-game-files:/app/server  # Docker-managed named volume
    environment:
      - VERSION=1.21.0-rc.1
      - CHANNEL=unstable
    user: "1000:1000"
volumes:
  vintage-story-game-files:
```

### Running with docker run
```
docker run -d \
  --name vintage_story \
  -p 42420:42420/tcp \
  -p 42420:42420/udp \
  -v /path/on/host:/app/data \
  -v vintage-story-game-files:/app/server \
  -e VERSION=1.21.0-rc.1 \
  -e CHANNEL=unstable \
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
