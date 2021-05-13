require 'capybara/rails'

# Use different Capybara ports when running tests in parallel
if ENV['TEST_ENV_NUMBER']
  Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
end

Capybara.register_driver :chrome_headless do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new

  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome_headless

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if self.class.metadata[:js] == true
      driven_by(:chrome_headless)
    else
      driven_by(:rack_test)
    end
  end
end
