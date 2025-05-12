require 'rails_helper'

RSpec.describe SupportInterface::ProvidersFilter do
  describe '#filter_records' do
    it 'filters by having one or more courses' do
      provider_with_course = create(:provider, :unsigned)
      create(:course, :open, provider: provider_with_course)
      create(:provider, :unsigned)
      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[with_courses] })

      expect(filter.filter_records(providers)).to eq [provider_with_course]
    end

    it 'filters by DSA signed' do
      provider_with_signed_dsa = create(:provider)
      create(:provider, :unsigned)

      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[dsa_signed_only] })

      expect(filter.filter_records(providers)).to eq [provider_with_signed_dsa]
    end

    it 'filters by DSA unsigned' do
      provider_with_unsigned_dsa = create(:provider, :unsigned)
      create_list(:provider, 2)

      providers = Provider.all
      filter = described_class.new(params: { onboarding_stages: %w[dsa_unsigned_only] })

      expect(filter.filter_records(providers)).to eq [provider_with_unsigned_dsa]
    end

    it 'filters by provider type' do
      lead_school = create(:provider, :unsigned, provider_type: 'lead_school')
      scitt = create(:provider, :unsigned, provider_type: 'scitt')

      filter = described_class.new(params: { provider_types: %w[lead_school] })
      expect(filter.filter_records(Provider.all)).to eq [lead_school]

      filter = described_class.new(params: { provider_types: %w[scitt] })
      expect(filter.filter_records(Provider.all)).to eq [scitt]

      filter = described_class.new(params: { remove: true })
      expect(filter.filter_records(Provider.all)).to contain_exactly(scitt, lead_school)
    end

    it 'filters by ratifying relationship' do
      ratified_by_scitt = create(:provider, :unsigned)
      scitt = create(:provider, :unsigned, provider_type: 'scitt')
      create(:provider_relationship_permissions,
             training_provider: ratified_by_scitt,
             ratifying_provider: scitt)

      ratified_by_hei = create(:provider, :unsigned)
      hei = create(:provider, :unsigned, provider_type: 'university')
      create(:provider_relationship_permissions,
             training_provider: ratified_by_hei,
             ratifying_provider: hei)

      filter = described_class.new(params: { ratified_by: %w[scitt] })
      expect(filter.filter_records(Provider.all)).to eq [ratified_by_scitt]

      filter = described_class.new(params: { ratified_by: %w[university] })
      expect(filter.filter_records(Provider.all)).to eq [ratified_by_hei]

      filter = described_class.new(params: { remove: true })
      expect(filter.filter_records(Provider.all)).to contain_exactly(
        ratified_by_hei,
        ratified_by_scitt,
        hei,
        scitt,
      )
    end

    it 'filters by providers with no provider users' do
      provider_with_provider_user = create(:provider, :unsigned)
      provider_without_provider_user = create(:provider, :unsigned, :no_users)

      filter = described_class.new(params: { no_provider_users: %w[true] })
      expect(filter.filter_records(Provider.all)).to eq [provider_without_provider_user]

      filter = described_class.new(params: { remove: true })
      expect(filter.filter_records(Provider.all)).to contain_exactly(provider_with_provider_user, provider_without_provider_user)
    end

    it 'filters by accredited provider' do
      accredited_provider = create(:provider, :unsigned, name: 'Accredited Provider')
      training_provider1 = create(:provider, :unsigned)
      training_provider2 = create(:provider, :unsigned)
      create(:course, provider: training_provider1, accredited_provider:)
      create(:course, provider: training_provider2, accredited_provider:)
      course_from_previous_cycle = create(:course, recruitment_cycle_year: previous_year, accredited_provider:)

      filter = described_class.new(params: { accredited_provider: 'accredited prov' })
      expect(filter.filter_records(Provider.all)).to contain_exactly(training_provider1, training_provider2)

      filter = described_class.new(params: { remove: true })
      expect(filter.filter_records(Provider.all)).to contain_exactly(accredited_provider, training_provider1, training_provider2, course_from_previous_cycle.provider)
    end

    it 'defaults to showing all providers' do
      create(:provider, :unsigned)
      create(:provider, :unsigned)
      create(:provider, :unsigned)
      create(:provider) # only signed

      providers = Provider.all
      filter = described_class.new(params: {})

      expect(filter.filter_records(providers).count).to eq(4)
    end
  end
end
