require 'rails_helper'

RSpec.describe WarmProviderCache do
  around do |example|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    example.run
    Rails.cache = original_cache
  end

  describe '#call' do
    it 'caches application_choices of a provider' do
      choice = create(
        :application_choice,
        :awaiting_provider_decision,
        updated_at: Time.zone.local(2024, 9, 4, 14, 0),
      )

      described_class.new.call('1.1', choice.provider.id)

      cached_choice = Rails.cache.read("vendor_api-1.1-application_choices/#{choice.id}-20240904130000000000")
      expect(cached_choice[:id]).to eq(choice.id.to_s)
    end
  end
end
