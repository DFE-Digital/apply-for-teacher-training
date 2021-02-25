# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Timecop.safe_mode = true

Faker::Config.locale = 'en-GB'

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include AbstractController::Translation

  config.include FactoryBot::Syntax::Methods

  config.include GeocodeTestHelper
  config.before do
    stub_const('Geokit::Geocoders::GoogleGeocoder', stub_geocoder)
  end

  config.before { Faker::UniqueGenerator.clear }

  config.before { ActionMailer::Base.deliveries.clear }

  config.before(:suite) do
    unless ENV['TEST_ENV_NUMBER']
      puts "ℹ️  If you change CSS, JS, or Assets - don't forget to run `rake compile_assets` before your test runs"
      puts "ℹ️  Running tests with all features #{ENV['DEFAULT_FEATURE_FLAG_STATE'] == 'on' ? 'ON' : 'OFF'} by default (run with DEFAULT_FEATURE_FLAG_STATE=on/off to change)"
    end
  end

  config.before do
    if ENV['DEFAULT_FEATURE_FLAG_STATE'] == 'on'
      records = FeatureFlag::TEMPORARY_FEATURE_FLAGS.map do |name, _|
        { name: name, active: true, created_at: Time.zone.now, updated_at: Time.zone.now }
      end

      Feature.insert_all(records)
    end
  end

  # Make the ActiveModel matchers like `validate_inclusion_of` available to form objects
  config.define_derived_metadata(file_path: Regexp.new('/spec/forms/')) do |metadata|
    metadata[:type] = 'model'
  end

  FactoryBot::SyntaxRunner.class_eval do
    include RSpec::Mocks::ExampleMethods
  end
end
