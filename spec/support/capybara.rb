require 'capybara/rails'
require 'capybara/apparition'

Capybara.register_driver :apparition do |app|
  Capybara::Apparition::Driver.new(app, headless: false)
end
Capybara.javascript_driver = :apparition

# Capybara.register_driver :apparition_debug do |app|
#   Capybara::Apparition::Driver.new(app, :inspector => true, headless: false)
# end
# # Capybara.javascript_driver = :apparition
# Capybara.javascript_driver = :apparition_debug

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end
end
