require 'rails_helper'

RSpec.describe ActiveSupport::Cache::SplitterCacheStore do
  subject(:store) { described_class.new(options) }

  let(:options) do
    {
      caches: {
        redis: [:redis_cache_store, { url: 'redis://localhost:6379/0' }],
        solid_cache: :solid_cache_store,
      },
    }
  end

  describe '.supports_cache_versioning?' do
    it 'returns true' do
      expect(described_class.supports_cache_versioning?).to be(true)
    end
  end

  describe '#new' do
    it 'initialises the caches' do
      expect(store.caches[:redis].class).to eq(
        ActiveSupport::Cache::RedisCacheStore,
      )
      expect(store.caches[:solid_cache].class).to eq(
        ActiveSupport::Cache::SolidCacheStore,
      )
    end
  end

  context 'use solid_cache' do
    describe '#fetch' do
      it 'writes and fetches the value' do
        store.write('vendor_api', 'value')
        expect(store.caches[:solid_cache].fetch('vendor_api')).to eq('value')
        expect(store.fetch('vendor_api')).to eq('value')
      end
    end

    describe '#read' do
      it 'writes and reads the value' do
        store.write('vendor_api', 'value')
        expect(store.caches[:solid_cache].read('vendor_api')).to eq('value')
        expect(store.read('vendor_api')).to eq('value')
      end
    end

    describe '#delete' do
      it 'writes and delets the value' do
        store.write('vendor_api', 'value')
        store.delete('vendor_api')
        expect(store.caches[:solid_cache].read('vendor_api')).to be_nil
      end
    end

    describe '#increment' do
      it 'writes and increments' do
        store.write('vendor_api', 1, raw: true)
        expect(store.increment('vendor_api')).to eq(2)
      end
    end

    describe '#exist?' do
      it 'writes and check exist?' do
        store.write('vendor_api', 'value')
        expect(store.caches[:solid_cache].exist?('vendor_api')).to be(true)
        expect(store.exist?('vendor_api')).to be(true)
      end
    end

    describe '#clear?' do
      it 'clears redis not solid_cache' do
        store.write('vendor_api', 'value')
        store.clear
        expect(store.caches[:solid_cache].read('vendor_api')).to eq('value')
      end
    end
  end

  context 'use redis' do
    describe '#fetch' do
      it 'writes and fetches the value' do
        store.write('test', 'value')
        expect(store.caches[:redis].fetch('test')).to eq('value')
        expect(store.fetch('test')).to eq('value')
      end
    end

    describe '#read' do
      it 'writes and reads the value' do
        store.write('test', 'value')
        expect(store.caches[:redis].read('test')).to eq('value')
        expect(store.read('test')).to eq('value')
      end
    end

    describe '#delete' do
      it 'writes and delets the value' do
        store.write('test', 'value')
        store.delete('test')
        expect(store.caches[:redis].read('test')).to be_nil
      end
    end

    describe '#increment' do
      it 'writes and increments' do
        store.write('test', 1, raw: true)
        expect(store.increment('test')).to eq(2)
      end
    end

    describe '#exist?' do
      it 'writes and check exist?' do
        store.write('test', 'value')
        expect(store.exist?('test')).to be(true)
        expect(store.caches[:redis].exist?('test')).to be(true)
      end
    end

    describe '#clear?' do
      it 'writes and clears redis' do
        store.write('test', 'value')
        store.clear
        expect(store.caches[:redis].read('test')).to be_nil
      end
    end
  end
end
