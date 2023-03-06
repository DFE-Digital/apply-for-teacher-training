#!/bin/bash

echo "Setting SSH password for vscode user..."
sudo usermod --password $(echo vscode | openssl passwd -1 -stdin) vscode

echo "Updating RubyGems..."
gem update --system

echo "Installing dependencies..."
bundle install
yarn install

echo "Copying database.yml..."
cp config/database.yml.example config/database.yml

echo "Creating database..."
bin/rails db:setup

echo "Set up local dev data..."
bundle exec rake setup_local_dev_data

echo "Run Sidekiq"
SERVICE_TYPE=worker bundle exec sidekiq -c 5 -C config/sidekiq-main.yml

echo "Done!"
