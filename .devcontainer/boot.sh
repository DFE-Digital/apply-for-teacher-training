#!/bin/bash

echo "Setting SSH password for vscode user..."
sudo usermod --password $(echo vscode | openssl passwd -1 -stdin) vscode

echo "Updating RubyGems..."
gem update --system

echo "Installing dependencies..."
bundle install
yarn install

echo "Creating database..."
bin/rails db:setup

echo "Setting up local dev data..."
bundle exec rake setup_local_dev_data

mkdir -p tmp/pids
echo "Run bin/dev to start the application processes."

echo "Done!"
