require 'rails_helper'

RSpec.describe ActiveSupport::Cache::SplitterCacheStore do
  describe '.supports_cache_versioning?' do
    it 'returns true' do
      expect(described_class.supports_cache_versioning?).to be(true)
    end
  end

  describe '#new' do
    it 'initialises the caches' do
      options = {
        caches: {
          redis: [:redis_cache_store, { url: ENV.fetch('REDIS_CACHE_URL') }],
          solid_cache: :solid_cache_store,
        },
      }
      store = described_class.new(options)

      expect(store.caches[:redis].class).to eq(
        ActiveSupport::Cache::RedisCacheStore,
      )
      expect(store.caches[:solid_cache].class).to eq(
        ActiveSupport::Cache::SolidCacheStore,
      )
    end
  end

  describe '#fetch' do
    it 'fetches the value' do
      options = {
        caches: {
          redis: [:redis_cache_store, { url: ENV.fetch('REDIS_CACHE_URL') }],
          solid_cache: :solid_cache_store,
        },
      }
      store = described_class.new(options)
      store.caches[:redis].write('test', 'value')
      expect(store.caches[:redis].fetch('test')).to eq('value')

      ## Set things in before
      ## Test both caches
    end
  end
end
