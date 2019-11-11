web: SERVICE_TYPE=web bundle exec puma -C config/puma.rb
worker: SERVICE_TYPE=worker bundle exec sidekiq -c 5
clock: SERVICE_TYPE=clock bundle exec clockwork config/clock.rb
