source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 5.2.2', '>= 5.2.2.1'
gem 'puma', '~> 4.0'
gem 'pg', '~> 1.1.4'

gem 'webpacker'
gem 'rubocop'
gem 'rubocop-rspec'
gem 'govuk-lint'

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'capybara', '>= 3.24'
  gem 'shoulda-matchers', '~> 4.0'
end

group :development, :test do
  gem 'rspec-rails'
end
