# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../config/environment', __dir__)

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

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
require 'rspec/rails'
require 'dotenv/rails'

CYCLE_DATES.each do |recruitment_cycle_year, dates|
  RecruitmentCycleTimetable.find_or_create_by(recruitment_cycle_year:).tap do |timetable|
    timetable.update(
      find_opens_at: dates[:find_opens],
      apply_opens_at: dates[:apply_opens],
      apply_deadline_at: dates[:apply_deadline],
      reject_by_default_at: dates[:reject_by_default],
      decline_by_default_at: dates[:find_closes] - 1.day,
      find_closes_at: dates[:find_closes],
      christmas_holiday_range: dates.dig(:holidays, :christmas),
      easter_holiday_range: dates.dig(:holidays, :easter),
    )
  end
end

STANDARD_TEST_DATES = {
  'after_apply_deadline' => (RecruitmentCycleTimetable.current_timetable.apply_deadline_at + 1.hour).to_fs,
  'before_apply_reopens' => (RecruitmentCycleTimetable.current_timetable.apply_reopens_at - 1.day).to_fs,
  'after_apply_reopens' => (RecruitmentCycleTimetable.current_timetable.apply_reopens_at + 1.day).to_fs,
}.freeze

test_date_time_var = ENV.fetch('TEST_DATE_AND_TIME', 'real_world')
test_date_time = STANDARD_TEST_DATES.fetch(test_date_time_var, test_date_time_var)

TestSuiteTimeMachine.pretend_it_is(test_date_time)

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }
require 'capybara/rails'

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Faker::Config.locale = 'en-GB'

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec::Matchers.define :have_csv_files do |csv_filename|
  match do |zip_file|
    Zip::File.open(zip_file) do |zip|
      csv_files = zip.glob(csv_filename)
      csv_files.any? && csv_files.all?(&:file?)
    end
  end

  failure_message do |zip_file|
    "expected #{zip_file} to contain CSV files matching #{csv_filename}"
  end

  failure_message_when_negated do |zip_file|
    "expected #{zip_file} not to contain CSV files matching #{csv_filename}"
  end
end

RSpec::Matchers.define :have_csv_file_content do |filename, expected_content|
  match do |zip_file|
    csv_data = read_csv_from_zip(zip_file, filename)
    csv_data == CSV.parse(expected_content, headers: true).to_a
  end

  failure_message do |zip_file|
    "Expected #{zip_file} to have CSV file #{filename} with content:\n#{expected_content}\n\nbut found:\n#{read_csv_from_zip(zip_file, filename)}"
  end

  def read_csv_from_zip(zip_file, filename)
    Zip::File.open(zip_file) do |zip|
      csv_data = zip.glob(filename).first.get_input_stream.read
      CSV.parse(csv_data, headers: true).to_a
    end
  end
end

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join('spec/fixtures').to_s]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.include WorkloadIdentityFederationStubs
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include CapybaraRSpecMonkeyPatch, type: :system

  config.extend FactorySpecHelpers

  config.include CycleTimetableHelper
  config.extend CycleTimetableHelper
  config.include TestSuiteTimeMachine::RSpecHelpers

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
  config.before do
    allow(Postcodes::IO).to receive(:new).and_return(instance_double(Postcodes::IO, lookup: nil))
  end

  config.before { Rails.cache.clear }
  config.before { Faker::UniqueGenerator.clear }
  config.before { ActionMailer::Base.deliveries.clear }

  config.before(bullet: true) do
    SetupBullet.call
  end

  config.before(:suite) do
    unless ENV['TEST_ENV_NUMBER']
      puts "ℹ️  If you change CSS, JS, or Assets - don't forget to run `rake compile_assets` before your test runs"
      puts "ℹ️  Running tests with all features #{ENV['DEFAULT_FEATURE_FLAG_STATE'] == 'on' ? 'ON' : 'OFF'} by default"
    end
  end

  config.before do
    RequestStore.store[:allow_unsafe_application_choice_touches] = true

    if ENV['DEFAULT_FEATURE_FLAG_STATE'] == 'on'
      records = FeatureFlag::TEMPORARY_FEATURE_FLAGS.map do |name, _|
        { name:, active: true, created_at: Time.zone.now, updated_at: Time.zone.now }
      end

      Feature.insert_all(records)

      FeatureFlag.deactivate(:adviser_sign_up)
    end
  end

  config.define_derived_metadata(file_path: Regexp.new('/spec/system/')) do |metadata|
    metadata[:type] = 'system' if metadata[:type].blank?
  end

  # Make the ActiveModel matchers like `validate_inclusion_of` available to form objects
  config.define_derived_metadata(file_path: Regexp.new('/spec/forms/')) do |metadata|
    metadata[:type] = 'model'
  end

  FactoryBot::SyntaxRunner.class_eval do
    include RSpec::Mocks::ExampleMethods
  end

  config.before(type: 'system') do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
  end

  config.around do |example|
    TestSuiteTimeMachine.reset
    example.run
    TestSuiteTimeMachine.reset
  end

  config.after do
    TestSuiteTimeMachine.pretend_it_is(test_date_time) if TestSuiteTimeMachine.baseline.nil?
  end

  # Use `feature_flag: :some_feature_flag` to activate a feature flag for a test
  config.around(:each, :feature_flag) do |example|
    FeatureFlag.activate(example.metadata[:feature_flag]) do
      example.run
    end
  end
end
