source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 6.0'
gem 'puma', '~> 4.2'
gem 'pg', '~> 1.1.4'

gem 'webpacker'
gem 'govuk_design_system_formbuilder', '0.9.4'

# GovUK Notify
gem 'mail-notify'

# Linting
gem 'rubocop'
gem 'rubocop-rspec'
gem 'govuk-lint'
gem 'erb_lint', require: false

# State machine
gem 'aasm'

# Calculate working days
gem 'business_time'
gem 'holidays'

# Authorisation
gem 'pundit'
gem 'devise'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'aasm-diagram'
  gem 'rails-erd'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara', '>= 3.24'
  gem 'shoulda-matchers', '~> 4.1'
  gem 'rspec_junit_formatter'
  gem 'capybara-email'
  gem 'climate_control'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'timecop'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
end
