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

echo "Run Sidekiq and Rails"
mkdir tmp/pids

SERVICE_TYPE=web bundle exec puma -C config/puma.rb
SERVICE_TYPE=worker bundle exec sidekiq -c 5 -C config/sidekiq-main.yml

echo "Done!"
