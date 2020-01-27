source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'rails', '~> 6.0'
gem 'puma', '~> 4.3'
gem 'pg', '~> 1.2.2'

gem 'webpacker'
gem 'govuk_design_system_formbuilder', '1.1.3'

# GovUK Notify
gem 'mail-notify'

gem 'redcarpet'

# Linting
gem 'rubocop-govuk'
gem 'erb_lint', require: false

gem 'devise'
gem 'omniauth'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'

gem 'workflow'
gem 'audited'

gem 'json-schema'
gem 'json_api_client'

gem 'sentry-raven'

gem 'factory_bot_rails'
gem 'faker'

gem 'actionview-component'

gem 'uk_postcode'

gem 'business_time'
gem 'holidays'

# feature flags
gem 'rollout'

# Logging
gem 'lograge'
gem 'logstash-logger'
gem 'logstash-event'
gem 'request_store_rails'
gem 'request_store-sidekiq'

# Background processing
gem 'sidekiq'
gem 'clockwork'

# For outgoing http requests
gem 'http'

# For DSI api integration
gem 'jwt'

gem 'openapi3_parser', '0.8.0'
gem 'rouge'
gem 'ruby-graphviz'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'rails-erd'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara', '>= 3.24'
  gem 'shoulda-matchers', '~> 4.2'
  gem 'rspec_junit_formatter'
  gem 'capybara-email'
  gem 'climate_control'
  gem 'launchy'
  gem 'timecop'
  gem 'guard-rspec'
  gem 'webmock'
  gem 'simplecov', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'clockwork-test'
  gem 'deepsort'
  gem 'rspec-benchmark'
end

group :development, :test do
  gem 'brakeman'
  gem 'rspec-rails'
  gem 'db-query-matchers'
  gem 'dotenv-rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'bullet'
end
