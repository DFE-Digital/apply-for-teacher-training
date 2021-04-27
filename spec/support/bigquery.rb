RSpec.configure do |config|
  config.before do |example|
    allow(SendRequestEventsToBigquery).to receive(:perform_async) if example.metadata[:with_bigquery].blank?
  end
end
