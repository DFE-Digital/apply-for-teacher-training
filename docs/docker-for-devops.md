# Docker for DevOps

## Purpose

This document describes the docker image used by the apply for teacher training service in the context of the DevOps engineers who maintain and deploy it. The document covers the struture of the multi-stage docker image we use and how to run the image in both developer and production mode, the latter being used when hosted in Azure.

## Docker and Docker Compose

Docker will build an image from a Docker file and enable you to run and interact with the container based on it. Docker Compose on the other hand is used for defining multi-container Docker architectures that allows you to launch such environments from a single command instead of having to pull several images and launch all the containers manually. In the case of the Apply service we have a Dockerfile that defines an image that can be launched in a number of modes and the Docker Compose file defines and launches all the dependent services required by the application, such as PostgreSQL and Redis.

## Docker image structure

The apply service uses a single image for the 'clock' and 'worker' Azure Container Instances as well as the Linux Application Service resource. Each container instance is launched with a different start command but is based on a common image.

The way that developers and the production service interact with the Docker image varies and consequently we have different build targets in our Dockerfile based on the same baseline image and application codebase. The most significant difference is that the production image is not bundled with any of the build dependencies to save space and reduce the number of potential vulnerability sources. The dev version of the image is over 1GB in size, the production image is nearer 200MB.

The diagram below shows the hierachy of the image layers used to build our final **dev-build** and **prod-build** target images that are used by the developers and Azure deployments respectively. The images are defined in the [Dockerfile](../Dockerfile)

```
               ┏━━━━━━━━━━━━━━━━━━━━━ ruby:2.6.6-alpine ━━━━━━━━━━━━━━━━━━━━━┓
               ┃                                                             ┃
               V                                                             ┃
    ┏━━ common-build-env ━━┓                                                 ┃
    ┃                      ┃                                                 ┃
    V                      V                                                 V
dev-build             prod-minify ━━━(copy app and compiled assets)━━━> prod-build
```
## Compose files

The following files are used in Apply's docker compose implementation.

- [docker-compose.yml](../docker-compose.yml)
  - This file contains the components of the docker environment that are common to both local development and Azure production deployments. This file defines the images required for the Postgres database, Redis cache, application and worker instances and their dependencies.
- [docker-compose.override.yml](../docker-compose.override.yml)
  - The override file is automatically loaded at run time by docker compose if it exists and contains overrides to the main `docker-compose.yml` file that apply only to development environments. These overrides include the use of local volumes for data persistance and targeting the 'dev-build' image.
- [docker-compose.azure.yml](../docker-compose.azure.yml)
  - The azure override file contains the overrides specific to the production image used in Azure. These changes include targeting the 'prod-build' image, configuring bundler not to include development dependencies and changing the image name to a format that can be pushed to DockerHub.

The Azure pipeline is configures docker compose to use the `docker-compose.azure.yml` file for overrides instead of the default `docker-compose.override.yml` in line 38 of the `azure-pipelines.yml` file. To run a production build locally you must rename the azure file to become the override file as described in the instructions later in this document.

## Makefile

To make interacting with the Docker images simpler the developers have created a [Makefile](../Makefile). Some useful commands from this Makefile are summarised below:
- `make build`: This will build the target docker image as specified in your Docker compose file.
- `make setup`: This will build the target docker image if not already present and set up the database.

The following commands all require you to have built and setup the container with the commands above before they will run.
- `make serve`: This will run the Docker container in headless mode so that you can interact with the web interface on port 3000.
- `make shell`: This will launch the Docker container and drop you into a shell environment to interface with the container like any other Linux environment. Run the `exit` command to return to your local terminal.
- `make test` and `make ci.*`: These command will run the various test suites against the application.
   - _NOTE 1: Set_ `RAILS_ENV=test` _in_ `.env` _and ensure_ `make setup` _has been run since the environment variable was changed prior to running the tests._
   - _NOTE 2: Testing should be done based on the 'dev-build' image target as descirbed below. If you have previously done a prod target build you will need to restore the content of the_ `docker-compose.override.yml` _file and amend the environment variables in the_ `.env` _file._

## Building the Docker images

### Build environment

Before attempting to build any of the docker environments you will require a Linux desktop/laptop/virtual machine environment with the following packages installed:
- `docker`
- `docker-compose`
- `git`
- `make`

It is recommended you install the latest docker and docker-compose packages directly from the Docker public repos rather than using the downstream versions in your distribution's own repos since these are invariably serveral versions behind the latest version available direct from Docker which may result in the Docker image not building correctly. It is also advisable to add your user account to the 'docker' group to remove the need for `sudo` everytime you run a Docker command.

_NOTE: The environment variables below that are set to 'test' will be sufficient to get the application to launch, however it may not guarantee that the application will function correctly. Correct functioning of the associated feature will require a valid value to be specified for any given environment variable._

### Building and running the 'dev-build' image target locally

1. Launch a terminal and clone the `apply-for-teacher-training` Git repo.
1. Create a copy of the [.env.development](../.env.development) file and name it `.env`.
1. Edit the `.env` file ane append the following additional envrionment variables to the end of the file.
   - `GOVUK_NOTIFY_API_KEY=test`
   - `RAILS_ENV=development`
1. Run the `make build` command. This will take approximately five minutes to complete.
1. Run the `make setup` command to initialise the database.
1. Run the `make serve` or `make shell` command to interact with the image as required. By default the application will run on port 3000. The first time you access the page it may take a short while to respond while the assets are compiled by the server, you should see this happening in the terminal window where you ran the container.

### Building and running the 'prod-build' image target locally

Under normal circumstances you will seldom need to run a build using these instructions. It is only required if a build in Azure fails and you need to reproduce the failure locally to debug.

1. Launch a terminal and clone the `apply-for-teacher-training` Git repo.
1. Create a copy of the [.env.development](../.env.development) file and name it `.env`.
1. Edit the `.env` file and append the following additional envrionment variables to the end of the file.
   - `GOVUK_NOTIFY_API_KEY=test`
   - `RAILS_ENV=production`
   - `SECRET_KEY_BASE=test`
   - `AUTHORISED_HOSTS=localhost` (_NOTE: If you are not running the Docker image locally this variable will need to be set to the hostname or IP address of the host running the service. This variable can accept multiple values as a comma separated list if required._)
   - `RAILS_SERVE_STATIC_FILES=true`
1. Take a backup of the [docker-compose.override.yml](../docker-compose.override.yml) file by renaming it to something else of your choosing.
1. Take a copy of the [docker-compose.azure.yml](../docker-compose.azure.yml) and name it `docker-compose.override.yml` to replace the file you backed up in the previous step.
1. Open the new `docker-compose.override.yml` file and make the following changes to it:
   - Delete the line that starts `image:`
   - Remove `=${railsSecretKeyBase}` from the end of the line `- SECRET_KEY_BASE=${railsSecretKeyBase}`
1. Run the `make build` command. This will take approximately five minutes to complete.
1. Run the `make setup` command to initialise the database.
1. Run the `make serve` or `make shell` command to interact with the image as required. By default the application will run on port 3000.

_NOTE: Do not forget to restore the original configuration of the_ `docker_compose.override.yml` _file once you have finished using the prod image otherwise unexpected bahviour may be observed if you attempt to run a dev build or the tests._

## Useful docker commands

- `docker ps -a`: List all containers.
- `docker container rm <CONTAINER ID TO DELETE>`: Delete a container.
- `docker images`: List all Docker images present on the system.
- `docker rmi <CONTAINER NAME OR ID TO DELETE>`: Delete docker image(s).
- `docker-compose web up`: Run the Docker container.
- `docker-compons web down`: Stop the Docker container.
- `docker-compose run --rm web <SHELL COMMAND TO RUN>`: Run the docker container, execute the specified shell command and then remove the container on completion.
