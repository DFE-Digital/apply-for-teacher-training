require 'capybara/rails'

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  driver_path = ENV['CHROMEDRIVER_PATH']

  raise 'CHROMEDRIVER_PATH is required for running JS specs but is undefined in ENV' unless driver_path

  service = Selenium::WebDriver::Service.new(path: driver_path, port: 9005)

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')

  Capybara::Selenium::Driver.new(app, browser: :chrome, service: service, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, type: :system, js: true) do
    driven_by(:chrome_headless)
  end
end

Capybara.server = :puma, { Silent: true }
