require 'rails_helper'

RSpec.describe SupportInterface::ProvidersFilter do
  let!(:provider_with_synced_courses) { create(:provider, sync_courses: true) }
  let!(:provider_without_synced_courses) { create(:provider, sync_courses: false) }
  let!(:provider_with_signed_dsa) { create(:provider, :with_signed_agreement) }
  let!(:provider_with_nothing) { create(:provider) }

  describe '#filter_records' do
    it 'filters by synced courses' do
      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[synced] })

      expect(filter.filter_records(providers)).to eq [provider_with_synced_courses]
    end

    it 'filters by DSA signed' do
      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[dsa_signed] })

      expect(filter.filter_records(providers)).to eq [provider_with_signed_dsa]
    end

    it 'excludes providers when the boxes aren’t ticked' do
      providers = Provider.all
      filter = described_class.new(params: { remove: true })

      expect(filter.filter_records(providers)).to match_array [provider_with_nothing, provider_without_synced_courses]
    end
  end
end
