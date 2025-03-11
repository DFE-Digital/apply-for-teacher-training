source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.7'

gem 'timeliness'

gem 'rails', '~> 8.0.1'

gem 'puma', '~> 6.6'
gem 'pg', '~> 1.5.9'
gem 'blazer'
gem 'sprockets-rails'

# do not rely on host’s timezone data, which can be inconsistent
gem 'tzinfo-data'

gem 'webpacker'
gem 'google-cloud-bigquery'

gem 'govuk-components', '~> 5.8.0'
gem 'govuk_design_system_formbuilder', '~> 5.8.0'

# GOV.UK Notify
gem 'mail-notify'

gem 'notifications-ruby-client'

gem 'govuk_markdown'

# Linting
gem 'rubocop', require: false
gem 'rubocop-capybara', require: false
gem 'rubocop-factory_bot', require: false
gem 'rubocop-rails', require: false
gem 'rubocop-rake', require: false
gem 'rubocop-rspec', require: false
gem 'rubocop-rspec_rails', require: false
gem 'erb_lint', require: false

gem 'devise'
gem 'omniauth'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'

gem 'workflow'
gem 'audited'
gem 'discard'

gem 'json-schema'
gem 'json_api_client'

# Render smart quotes
gem 'rubypants'

# Oj is faster at rendering JSON than the default Rails JSON serializer
gem 'oj'

# We use a postgres sequence to generate public_ids for qualifications
# See adr/0018-public-ids-for-qualifications.md for details on why this is necessary
# This gem adds support for sequences in the schema.rb
gem 'ar-sequence'

gem 'active_hash', '~> 3.3.1'

# Allows the use of common table expressions / WITH statements
# in active record queries; may eventually be merged into Rails
gem 'activerecord-cte'

gem 'sentry-rails'
gem 'sentry-sidekiq'

gem 'factory_bot_rails'
gem 'satisfactory', '~> 0.3'

# Leave 2.22.0 otherwise it could fail generating applications in sandbox
gem 'faker', '2.22.0'

gem 'view_component'

gem 'uk_postcode'
gem 'postcodes_io'

gem 'business_time'
gem 'holidays'

gem 'humanize'

# Monitoring
gem 'okcomputer'
gem 'skylight'

gem 'prometheus-client'
gem 'yabeda-rails'
gem 'yabeda-puma-plugin'
gem 'yabeda-gc'
gem 'yabeda-sidekiq'
gem 'yabeda-http_requests'
gem 'yabeda-prometheus'

# Logging
gem 'request_store_rails'
gem 'request_store-sidekiq'
gem 'rails_semantic_logger', group: %w[development production]

# Background processing
gem 'sidekiq', '< 7'
gem 'clockwork'

# Rate limiting
gem 'rack-attack'

# For outgoing http requests
gem 'http'

# For DSI api integration
gem 'jwt'

gem 'openapi3_parser', '0.10.1'
gem 'rouge'
gem 'ruby-graphviz'

gem 'pagy'
gem 'bcrypt'

# Adviser sign up integration
gem 'get_into_teaching_api_client_faraday', github: 'DFE-Digital/get-into-teaching-api-ruby-client', require: 'api/client'

# PDF generation
gem 'grover'

gem 'archive-zip'

# Geocoding
gem 'geocoder'
gem 'geokit-rails'

gem 'dfe-reference-data', require: 'dfe/reference_data', github: 'DFE-Digital/dfe-reference-data', tag: 'v3.6.10'
gem 'dfe-autocomplete', require: 'dfe/autocomplete', github: 'DFE-Digital/dfe-autocomplete', tag: 'v0.1.0'
gem 'dfe-wizard', require: 'dfe/wizard', github: 'DFE-Digital/dfe-wizard', tag: 'v0.1.0'

gem 'strip_attributes'

# Automate checks for potentially unsafe migrations
gem 'strong_migrations'

# Rails console colours
gem 'colorize'

# Performance profiling - keep this below 'pg' gem
gem 'rack-mini-profiler', require: ['prepend_net_http_patch']

# BigQuery
gem 'dfe-analytics', github: 'DFE-Digital/dfe-analytics', tag: 'v1.15.4'

# Azure Blob Storage
gem 'azure-blob'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.10'
  gem 'rails-erd'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara-email'
  gem 'capybara', '>= 3.24'
  gem 'climate_control'
  gem 'clockwork-test'
  gem 'deepsort'
  gem 'guard-rspec'
  gem 'launchy'
  gem 'rspec_junit_formatter'
  gem 'rspec-retry', git: 'https://github.com/DFE-Digital/rspec-retry.git', branch: 'main'
  gem 'ruby-jmeter'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 6.4'
  gem 'simplecov-cobertura', require: false
  gem 'simplecov', require: false
  gem 'super_diff'
  gem 'test_suite_time_machine', '~> 2.0'
  gem 'timecop'
  gem 'webmock', '~> 3.25'
end

group :development, :test do
  gem 'brakeman'
  gem 'bullet', require: false
  gem 'dotenv-rails', require: false
  gem 'parallel_tests'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry'
  gem 'rspec-rails', require: false
end
