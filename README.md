# vintage-story-dedicated-docker

## Description
A simple image to run Vintage Story using docker. The container will download the game, and update upon restart.

## Setup
The setup requires only a directory for the saves file, config files and logs to be defined.

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
volumes:
  vintage-story-game-files:
```

### Editing the config
Configuration of the server takes place within the `app/data` mount in `serverconfig.json`

Variables are explained in the official Vintage Story documentation here https://wiki.vintagestory.at/Server_Config

To get started I recommend setting the following configs:
* `ServerName`
* `ServerDescription`
* `WelcomeMessage`
* `Password`
* `WorldConfig.SaveFileLocation` -- if you want to use an existing save
* `WhitelistMode` set to `off` if you want to rely only on password protection
