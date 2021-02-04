require 'rails_helper'

RSpec.describe SupportInterface::ProvidersFilter do
  describe '#filter_records' do
    it 'filters by synced courses' do
      provider_with_synced_courses = create(:provider, sync_courses: true)
      create(:provider, sync_courses: false)

      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[synced] })

      expect(filter.filter_records(providers)).to eq [provider_with_synced_courses]
    end

    it 'filters by DSA signed' do
      provider_with_signed_dsa = create(:provider, :with_signed_agreement)
      create(:provider)

      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[dsa_signed] })

      expect(filter.filter_records(providers)).to eq [provider_with_signed_dsa]
    end

    it 'filters by provider type' do
      lead_school = create(:provider, provider_type: 'lead_school')
      scitt = create(:provider, provider_type: 'scitt')

      filter = described_class.new(params: { provider_types: %w[lead_school] })
      expect(filter.filter_records(Provider.all)).to eq [lead_school]

      filter = described_class.new(params: { provider_types: %w[scitt] })
      expect(filter.filter_records(Provider.all)).to eq [scitt]

      filter = described_class.new(params: { remove: true })
      expect(filter.filter_records(Provider.all)).to match_array [scitt, lead_school]
    end

    it 'defaults to showing providers with synced courses and DSAs' do
      synced_and_signed = create(:provider, :with_signed_agreement, sync_courses: true)
      neither_synced_not_signed = create(:provider)
      create(:provider, sync_courses: true) # only synced
      create(:provider, :with_signed_agreement) # only signed

      providers = Provider.all
      filter = described_class.new(params: {})

      expect(filter.filter_records(providers)).to match_array([
        synced_and_signed,
      ])

      filter = described_class.new(params: { remove: true })

      expect(filter.filter_records(providers)).to eq [neither_synced_not_signed]
    end
  end
end
