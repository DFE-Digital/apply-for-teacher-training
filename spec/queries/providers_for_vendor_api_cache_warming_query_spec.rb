require 'rails_helper'

RSpec.describe ProvidersForVendorAPICacheWarmingQuery do
  include CourseOptionHelpers
  let(:primary_api_token) { build(:vendor_api_token, last_used_at: 1.week.ago) }
  let(:vendor_api_tokens) { [primary_api_token, build(:vendor_api_token, last_used_at: 1.week.ago)] }
  let!(:provider) { create(:provider, vendor_api_tokens:) }

  context 'when a provider has multiple api tokens' do
    it 'only returns one row per provider' do
      expect(described_class.new.call.length).to eq(1)
    end
  end

  context 'when the last_used_at is nil' do
    let(:primary_api_token) { build(:vendor_api_token, last_used_at: nil) }
    let(:vendor_api_tokens) { [primary_api_token] }

    it 'does not return the provider' do
      expect(described_class.new.call).not_to include(provider)
    end
  end

  context 'when the last_used_at is greater than the since param' do
    let(:primary_api_token) { build(:vendor_api_token, last_used_at: 2.months.ago) }
    let(:vendor_api_tokens) { [primary_api_token] }

    it 'does not return the provider' do
      expect(described_class.new.call(since: 1.month.ago)).not_to include(provider)
    end
  end
end
