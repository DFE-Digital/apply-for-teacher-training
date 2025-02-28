require 'rails_helper'

RSpec.describe LocationSuggestions do
  subject(:suggestions) { suggestions_query.call }

  let(:query) { 'London' }
  let(:cache) { Rails.cache }
  let(:cache_expiration) { 7.days }
  let(:client) { instance_double(GoogleMapsAPI::Client) }

  let(:suggestions_query) do
    described_class.new(query, cache: cache, cache_expiration: cache_expiration)
  end

  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }

  before do
    allow(Rails).to receive(:cache).and_return(memory_store)
    Rails.cache.clear
  end

  describe '#call' do
    context 'when query is blank' do
      let(:query) { '' }

      it 'returns an empty array' do
        expect(suggestions).to eq([])
      end
    end

    context 'when suggestions are cached' do
      let(:cached_suggestions) { ['London Bridge', 'London Eye'] }

      before do
        cache.write(suggestions_query.send(:cache_key), cached_suggestions)
      end

      it 'returns the cached suggestions' do
        expect(suggestions).to eq(cached_suggestions)
        expect(cache.read(suggestions_query.send(:cache_key))).to eq(cached_suggestions)
      end
    end

    context 'when suggestions are not cached' do
      let(:api_response) { ['Big Ben', 'Tower of London'] }

      before do
        allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
        allow(client).to receive(:autocomplete).with(query).and_return(api_response)
      end

      it 'fetches and caches the suggestions' do
        expect(cache.read(suggestions_query.send(:cache_key))).to be_nil

        expect(suggestions_query.call).to eq(api_response)
        expect(cache.read(suggestions_query.send(:cache_key))).to eq(api_response)
      end
    end

    context 'when API call raises an error' do
      before do
        allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
        allow(client).to receive(:autocomplete).and_raise(StandardError, 'API failure')
        allow(Sentry).to receive(:capture_exception)
      end

      it 'returns an empty array' do
        expect(suggestions).to eq([])
      end

      it 'captures the error in Sentry' do
        suggestions
        expect(Sentry).to have_received(:capture_exception).with(
          instance_of(StandardError),
          hash_including(message: "Location suggestion failed for LocationSuggestions - #{query}, suggestions ignored (user experience unaffected)"),
        )
      end
    end
  end

  describe '#cache_key' do
    let(:query) { 'London, UK' }

    it 'returns the formatted cache key' do
      expect(suggestions_query.send(:cache_key)).to eq('location:suggestions:london-uk')
    end
  end
end
