web: SERVICE_NAME=web bundle exec puma -C config/puma.rb
worker: SERVICE_NAME=worker bundle exec sidekiq -c 5
clock: SERVICE_NAME=clock bundle exec clockwork config/clock.rb
