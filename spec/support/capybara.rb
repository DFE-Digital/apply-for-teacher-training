require 'capybara/rails'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end
end
