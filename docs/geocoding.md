# Geocoding

## Purpose

This document describes how Geocoding functionality is configured in Apply.

## Configuration

We use the Google Maps API for geocoding of addresses. Keys are managed via the [Google Cloud Platform console](https://console.cloud.google.com/google/maps-apis/credentials).

The production key is restricted to an Apply IP whitelist. A development key is available for local testing. Speak to a team lead to obtain access to the console, from which either credential can be retrieved.

The key is made available to the codebase via the `GOOGLE_MAPS_API_KEY` environment variable.
