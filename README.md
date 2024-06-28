# Ravi's ActualBudget Server

Contains scripts and configuration settings for Ravi's local server.

## Pre-requisites

- [Docker](https://docs.docker.com/engine/install/)
- Linux Environment
    - On Windows, recommend [WSL 2.0](https://learn.microsoft.com/en-us/windows/wsl/install)

## Setup

`./start.sh` is a script that will either start or update actual-server for you.

- Depends on docker-compose.yml directly in the git submodule for actual-server
    - Make sure to run `git submodule init` and `git submodule update`
    - Make sure to comment out `environment:` in the `docker-compose.yml` file in the submodule
- Sets up HTTPS by generating a self-signed certificate in the appropriate directory

You're all set!
