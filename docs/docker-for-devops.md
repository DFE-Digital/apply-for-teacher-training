# Apply for Teacher Training - Docker for DevOps

## Purpose

This document describes the docker image used by the apply for teacher training service in the context of the DevOps engineers who maintain and deploy it. The document covers the struture of the multi-stage docker image we use and how to run the image in both developer and production mode, the latter being used when hosted in Azure.

## Docker and Docker Compose

Docker will build an image from a Docker file and enable you to run and interact with the container based on it. Docker Compose on the other hand is used for defining multi-container Docker architectures that allows you to launch such environments from a single command instead of having to pull and launch several containers manually. In the case of the Apply service we have a Dockerfile that defines an image that can be launched in a number of modes and the Docker Compose file defines and launches all the dependent services required by the application, such as PostgreSQL and Redis.

## Docker image structure

The apply service uses a single image for the 'clock' and 'worker' container instances as well as the Linux Appliction Service. Each container instance is launched with a different start command but based on a common image.

The way that developers and the production service interact with the Docker image varies and consequently we have different build targets in our Dockerfile based on the same baseline image and application codebase. The most siginifcant difference is that the production image is not bundled with any of the build dependencies to save space and reduce the number of potential vulnerability sources. The dev version of the image is over 1GB in size, the production image is nearer 200MB.

The diagram below shows the hierachy of the image layers used to build our final **dev-build** and **prod-build** target images that are used by the developers and Azure deployments respectively. The images are defined in the [Dockerfile](../Dockerfile)

```
               ---------------------- ruby:2.6.5-alpine ----------------------
               |                                                             |
               V                                                             |
    --- common-build-env ---                                                 |
    |                      |                                                 |
    V                      V                                                 V
dev-build             prod-minify ---(copy app and compiled assets)---> prod-build
```

## Makefile

To make interacting with the Docker images simpler the developers have created a [Makefile](../Makefile). Some useful commands from this Makefile are summarised below:
- `make build`: This will build the target docker image as specified in your Docker compose file.
- `make setup`: This will build the target docker image if not already present and set up the database.

The following commands all require you to have built and setup the container with the commands above before they will run.
- `make serve`: This will run the Docker container in headless mode so that you can interact with the web interface on port 3000.
- `make shell`: This will launch the Docker container and drop you into a shell environment to interface with the container like any other Linux environment. Run the `exit` command to return to your local terminal.
- `make test` and `make ci.*`: These command will run the various test suites against the application.

## Building the Docker images

### Build environment

Before attempting to build any of the docker environments you will require a Linux desktop/laptop/virtual machine environment with the following packages installed:
- `docker`
- `docker-compose`
- `git`
- `make`

It is recommended you install the latest docker and docker-compose packages directly from the Docker public repos rather than using the downstream versions in your distribution's own repos since these are invariably serveral versions behind the latest version available direct from Docker which may result in the Docker image not building correctly.

_NOTE: The environment variables below that are set to 'test' will be sufficient to get the application to launch, however it may not guarantee that the application will function correctly. Correct functioning of the associated feature will require a valid value to be specified for any given environment variable_

### Building and runinng the 'dev-build' image target locally

1. Launch a terminal and clone the `apply-for-teacher-training` Git repo.
1. Create a copy of the [.env.development](../.env.development) file and name it `.env`.
1. Edit the .env file ane append the following additional envrionment variables to the end of the file.
   - `GOVUK_NOTIFY_API_KEY=test`
   - `RAILS_ENV=development`
1. Run the `make build` command. This will take approximately five minutes to complete.
1. Run the `make setup` command to initialise the database.
1. Run the `make serve` or `make shell` command to interact with the image as required. By default the application will run on port 3000. The first time you access the page it may take a short while to respond while the assets are compiled by the server, you should see this happening in the terminal window where you ran the container.

### Building and running the 'prod-build' image target locally

1. Launch a terminal and clone the `apply-for-teacher-training` Git repo.
1. Create a copy of the [.env.development](../.env.development) file and name it `.env`.
1. Edit the .env file and append the following additional envrionment variables to the end of the file.
   - `GOVUK_NOTIFY_API_KEY=test`
   - `SECRET_KEY_BASE=test`
   - `AUTHORISED_HOSTS=localhost` (_NOTE: If you are not running the Docker image locally, this will need to be the hostname or IP address of the host_)
   - `RAILS_SERVE_STATIC_FILES=true`
   - `RAILS_ENV=production`
1. Take a backup of the [docker-compose.override.yml](../docker-compose.override.yml) file by renaming it to something else of your choosing.
1. Take a copy of the [docker-compose.azure.yml](../docker-compose.azure.yml) and name it `docker-compose.override.yml` to replace the file you backed up in the previous step.
1. Open the new `docker-compose.override.yml` file and make the following changes to it:
   - Delete the line that starts `image:` 
   - Remove `=${railsSecretKeyBase}` from the end of the line `- SECRET_KEY_BASE=${railsSecretKeyBase}`
1. Run the `make build` command. This will take approximately five minutes to complete.
1. Run the `make setup` command to initialise the database.
1. Run the `make serve` or `make shell` command to interact with the image as required. By default the application will run on port 3000.

## Useful docker commands

- `docker ps -a`: List all containers.
- `docker container rm <CONTAINER ID TO DELETE>`: Delete a container.
- `docker images`: List all Docker images present on the system.
- `docker rmi <CONTAINER NAME OR ID TO DELETE>`: Delete docker image(s).
- `docker-compose web up`: Run the Docker container.
- `docker-compons web down`: Stop the Docker container.
- `docker-compose run --rm web <SHELL COMMAND TO RUN>`: Run the docker container, execute the specified shell command and then remove the container on completion.
