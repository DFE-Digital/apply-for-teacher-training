#!/usr/bin/env sh
IMAGE=ghcr.io/dfe-digital/apply-jmeter-runner:latest

docker build -t $IMAGE .
docker push $IMAGE
