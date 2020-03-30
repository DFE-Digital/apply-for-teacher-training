require 'capybara/rails'
require 'capybara/apparition'

Capybara.javascript_driver = :apparition

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end
end
