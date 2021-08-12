source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.4'

gem 'activesupport', '~> 6.1'
gem 'actionpack', '~> 6.1'
gem 'actionview', '~> 6.1'
gem 'activemodel', '~> 6.1'
gem 'activerecord', '~> 6.1'
gem 'actionmailer', '~> 6.1'
gem 'railties', '~> 6.1'
gem 'sprockets-rails'

gem 'puma', '~> 5.4'
gem 'pg', '~> 1.2.3'
gem 'blazer'

# do not rely on host’s timezone data, which can be inconsistent
gem 'tzinfo-data'

gem 'webpacker'
gem 'govuk-components'
gem 'govuk_design_system_formbuilder', '~> 2.7.2'

# GOV.UK Notify
gem 'mail-notify'

gem 'govuk_markdown'

# Linting
gem 'rubocop'
gem 'rubocop-rspec'
gem 'rubocop-rails'
gem 'rubocop-rake'
gem 'erb_lint', require: false

gem 'devise'
gem 'omniauth'
gem 'omniauth_openid_connect'
gem 'omniauth-rails_csrf_protection'

gem 'workflow'
gem 'audited', git: 'https://github.com/DFE-Digital/audited'
gem 'discard'

gem 'json-schema'
gem 'json_api_client'
# Oj is faster at rendering JSON than the default Rails JSON serializer
gem 'oj'

# We use a postgres sequence to generate public_ids for qualifications
# See adr/0018-public-ids-for-qualifications.md for details on why this is necessary
# This gem adds support for sequences in the schema.rb
gem 'ar-sequence'

gem 'active_hash'

# Allows the use of common table expressions / WITH statements
# in active record queries; may eventually be merged into Rails
gem 'activerecord-cte'

gem 'sentry-rails'
gem 'sentry-sidekiq'

gem 'factory_bot_rails'
gem 'faker'

gem 'view_component'

gem 'uk_postcode'

gem 'business_time'
gem 'holidays'

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

# Background processing
gem 'sidekiq'
gem 'clockwork'

# For outgoing http requests
gem 'http'

# For DSI api integration
gem 'jwt'

gem 'openapi3_parser', '0.9.0'
gem 'rouge'
gem 'ruby-graphviz'

gem 'kaminari'

# PDF generation
gem ENV['WKHTMLTOPDF_GEM'] || 'wkhtmltopdf-binary'
gem 'pdfkit'

gem 'archive-zip'

# Geocoding
gem 'geocoder'

gem 'strip_attributes'

# Automate checks for potentially unsafe migrations
gem 'strong_migrations'

# Rails console colours
gem 'colorize'

# Performance profiling - keep this below 'pg' gem
gem 'rack-mini-profiler', require: false

group :production do
  gem 'rails_semantic_logger'
end

# Data integration with Bigquery
gem 'google-cloud-bigquery'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.7'
  gem 'rails-erd'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara', '>= 3.24'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'rspec_junit_formatter'
  gem 'capybara-email'
  gem 'climate_control'
  gem 'launchy'
  gem 'timecop'
  gem 'guard-rspec'
  gem 'webmock', '~> 3.14'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
  gem 'clockwork-test'
  gem 'deepsort'
  gem 'ruby-jmeter'
  gem 'super_diff'
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
  gem 'parallel_tests'
end
