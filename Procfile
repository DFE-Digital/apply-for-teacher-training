web: SERVICE_TYPE=web bundle exec puma -C config/puma.rb
worker: SERVICE_TYPE=worker bundle exec sidekiq -c 5 -C config/sidekiq-main.yml
worker_secondary: SERVICE_TYPE=worker bundle exec sidekiq -c 5 -C config/sidekiq-secondary.yml
clock: SERVICE_TYPE=clock bundle exec clockwork config/clock.rb
