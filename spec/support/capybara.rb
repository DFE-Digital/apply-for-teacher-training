require 'capybara/rspec'

# Use different Capybara ports when running tests in parallel
if ENV['TEST_ENV_NUMBER']
  Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i
end
Capybara.default_normalize_ws = true

options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
  opts.add_argument('--no-sandbox')
  opts.add_argument('--disable-dev-shm-usage')
  opts.add_argument('--disable-gpu')
  opts.add_argument('--window-size=1400,1400')
  # Required for non-root user in containers
  opts.add_argument('--disable-setuid-sandbox')
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

Capybara.register_driver :chrome_headless do |app|
  options.add_argument('--headless')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end

  config.before(:each, :js, type: :system) do
    driven_by(:chrome_headless)
  end

  config.before(:each, :js_browser, type: :system) do
    driven_by(:chrome)
  end

  config.before(:each, :smoke) do
    Capybara.run_server = false
    Capybara.app_host = ENV.fetch('SMOKE_TEST_APP_HOST')

    Capybara.current_driver = :chrome_headless
  end
end
