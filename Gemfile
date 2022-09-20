source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'timeliness'

gem 'rails', '~> 7.0'

gem 'puma', '~> 5.6'
gem 'pg', '~> 1.4.3'
gem 'blazer'
gem 'sprockets-rails'

# do not rely on host’s timezone data, which can be inconsistent
gem 'tzinfo-data'

gem 'webpacker'
gem 'govuk-components', '~> 3.0.6'
gem 'govuk_design_system_formbuilder', '~> 3.1.2'

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

gem 'active_hash'

# Allows the use of common table expressions / WITH statements
# in active record queries; may eventually be merged into Rails
gem 'activerecord-cte'

gem 'sentry-rails'
gem 'sentry-sidekiq'

gem 'factory_bot_rails'
gem 'faker', '2.22.0'

gem 'view_component'

gem 'uk_postcode'
gem 'postcodes_io'

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
gem 'rails_semantic_logger', group: %w[production]

# Background processing
gem 'sidekiq'
gem 'clockwork'

# Rate limiting
gem 'rack-attack'

# For outgoing http requests
gem 'http'

# For DSI api integration
gem 'jwt'

gem 'openapi3_parser', '0.9.2'
gem 'rouge'
gem 'ruby-graphviz'

gem 'kaminari'

gem 'pagy'

# PDF generation
gem ENV['WKHTMLTOPDF_GEM'] || 'wkhtmltopdf-binary'
gem 'pdfkit'

gem 'archive-zip'

# Geocoding
gem 'geocoder'

gem 'dfe-reference-data', require: 'dfe/reference_data', github: 'DFE-Digital/dfe-reference-data', tag: 'v1.0.0'
gem 'dfe-autocomplete', require: 'dfe/autocomplete', github: 'DFE-Digital/dfe-autocomplete', tag: 'v0.1.0'

gem 'strip_attributes'

# Automate checks for potentially unsafe migrations
gem 'strong_migrations'

# Rails console colours
gem 'colorize'

# Performance profiling - keep this below 'pg' gem
gem 'rack-mini-profiler', require: ['prepend_net_http_patch']

# BigQuery
gem 'dfe-analytics', github: 'DFE-Digital/dfe-analytics', tag: 'v1.3.2'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.8'
  gem 'rails-erd'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara', '>= 3.24'
  gem 'shoulda-matchers', '~> 5.2'
  gem 'rspec_junit_formatter'
  gem 'capybara-email'
  gem 'climate_control'
  gem 'launchy'
  gem 'timecop'
  gem 'guard-rspec'
  gem 'webmock', '~> 3.18'
  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
  gem 'clockwork-test'
  gem 'deepsort'
  gem 'ruby-jmeter'
  gem 'super_diff'
  gem 'rspec-retry', git: 'https://github.com/DFE-Digital/rspec-retry.git', branch: 'main'
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
