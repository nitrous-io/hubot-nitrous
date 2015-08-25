# hubot-nitrous

hubot is a chat bot built on the [Hubot][hubot] framework.

## Installation

To install it you need to do the following steps:
- Configure your settings (example file on `bin/env.example`)
- Configure the upstart job on your system and start it. Now it only supports `Upstart` on `ubuntu`.
```
sudo cp ./hubot.conf /etc/init
sudo start hubot
```