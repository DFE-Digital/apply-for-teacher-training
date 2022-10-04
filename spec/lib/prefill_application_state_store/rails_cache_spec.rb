require 'rails_helper'

RSpec.describe PrefillApplicationStateStore::RailsCache do
  # We disable caching in tests, so we need to enable it for this test
  around do |example|
    previous_cache_store = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    example.run
  ensure
    Rails.cache = previous_cache_store
  end

  it 'expires the key after 5 minutes' do
    current_candidate_id = '12345'
    data = { value: 'value' }
    store = described_class.new(current_candidate_id)

    store.write(data)

    expect(store.read).to eq(data)

    Timecop.travel(5.minutes) do
      expect(store.read).to be_nil
    end
  end
end
