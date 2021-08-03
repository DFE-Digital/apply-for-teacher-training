require 'rails_helper'

RSpec.describe SupportInterface::ProvidersFilter do
  describe '#filter_records' do
    it 'filters by having one or more courses open on apply' do
      provider_with_course = create(:provider)
      create(:course, :open_on_apply, provider: provider_with_course)
      create(:provider)
      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[with_courses] })

      expect(filter.filter_records(providers)).to eq [provider_with_course]
    end

    it 'filters by DSA signed' do
      provider_with_signed_dsa = create(:provider, :with_signed_agreement)
      create(:provider)

      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[dsa_signed_only] })

      expect(filter.filter_records(providers)).to eq [provider_with_signed_dsa]
    end

    it 'filters by DSA unsigned' do
      provider_with_unsigned_dsa = create(:provider)
      create_list(:provider, 2, :with_signed_agreement)

      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[dsa_unsigned_only] })

      expect(filter.filter_records(providers)).to eq [provider_with_unsigned_dsa]
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

    it 'filters by ratifying relationship' do
      ratified_by_scitt = create(:provider)
      scitt = create(:provider, provider_type: 'scitt')
      create(:provider_relationship_permissions,
             training_provider: ratified_by_scitt,
             ratifying_provider: scitt)

      ratified_by_hei = create(:provider)
      hei = create(:provider, provider_type: 'university')
      create(:provider_relationship_permissions,
             training_provider: ratified_by_hei,
             ratifying_provider: hei)

      filter = described_class.new(params: { ratified_by: %w[scitt] })
      expect(filter.filter_records(Provider.all)).to eq [ratified_by_scitt]

      filter = described_class.new(params: { ratified_by: %w[university] })
      expect(filter.filter_records(Provider.all)).to eq [ratified_by_hei]

      filter = described_class.new(params: { remove: true })
      expect(filter.filter_records(Provider.all)).to match_array([
        ratified_by_hei,
        ratified_by_scitt,
        hei,
        scitt,
      ])
    end

    it 'defaults to showing all providers' do
      create(:provider, :with_signed_agreement, sync_courses: true)
      create(:provider)
      create(:provider, sync_courses: true) # only synced
      create(:provider, :with_signed_agreement) # only signed

      providers = Provider.all
      filter = described_class.new(params: {})

      expect(filter.filter_records(providers).count).to eq(4)
    end
  end
end
