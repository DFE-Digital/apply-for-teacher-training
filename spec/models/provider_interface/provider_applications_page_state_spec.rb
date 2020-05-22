require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsPageState do
  let(:course1) { create(:course) }
  let(:course2) { create(:course) }
  let(:course3) { create(:course) }

  let(:site1) { create(:site) }
  let(:site2) { create(:site) }

  let(:provider1) { create(:provider, courses: [course1], sites: [site1, site2]) }
  let(:provider2) { create(:provider, courses: [course2]) }
  let(:provider3) { create(:provider, courses: [course3]) }

  let(:provider_user) { create(:provider_user, providers: [provider1, provider2, provider3]) }
  let(:another_provider_user) { create(:provider_user, providers: [provider1]) }

  describe '#filters' do
    it 'calculates a correct list of possible filters' do
      page_state = described_class.new(params: ActionController::Parameters.new,
                                       provider_user: provider_user)

      expected_number_of_filters = 4
      providers_array_index = 2
      number_of_courses = 3

      expect(page_state.filters).to be_a(Array)
      expect(page_state.filters.size).to be(expected_number_of_filters)
      expect(page_state.filters[providers_array_index][:options].size).to be(number_of_courses)
    end

    it 'does not include providers if avaible providers is < 2' do
      page_state = described_class.new(params: ActionController::Parameters.new,
                                       provider_user: another_provider_user)

      expected_number_of_filters = 3

      headings = page_state.filters.map { |filter| filter[:heading] }

      expect(page_state.filters.size).to be(expected_number_of_filters)
      expect(headings).not_to include('Provider')
    end

    it 'can return filter config for a list of provider locations' do
      page_state = described_class.new(params: ActionController::Parameters.new({ provider: [provider1.id] }),

                                       provider_user: another_provider_user)

      headings = page_state.filters.map { |filter| filter[:heading] }

      expect(headings).to include("Locations for #{provider1.name}")

      # TODO: think if more specific test that tests multiple provider_locations
      expect(page_state.filters[3][:options][0][:value]).to eq(provider1.sites.first.id)
      expect(page_state.filters[3][:options][1][:value]).to eq(provider1.sites.last.id)

      expect(page_state.filters[3][:options][0][:label]).to eq(provider1.sites.first.name)
      expect(page_state.filters[3][:options][1][:label]).to eq(provider1.sites.last.name)
    end
  end

  xit 'will not renturn locations unless the provider filter is active' do
  end

  describe '#applied_filters' do
    let(:params) do
      ActionController::Parameters.new({ 'status' => %w[
        awaiting_provider_decision
        pending_conditions
        recruited
        declined
      ],
                                         'weekdays' => %w[
                                           wed
                                           thurs
                                           mon
                                         ] })
    end

    it 'returns a has of permitted parameters' do
      page_state = described_class.new(params: params, provider_user: provider_user)

      expect(page_state.applied_filters).to be_a(Hash)
      expect(page_state.applied_filters.keys).to include('status')
      expect(page_state.applied_filters.keys).not_to include('weekdays')
    end
  end

  describe '#filtered?' do
    let(:params) do
      ActionController::Parameters.new({ 'status' => %w[
        awaiting_provider_decision
        pending_conditions
        recruited
        declined
      ] })
    end

    let(:empty_params) { ActionController::Parameters.new }

    it 'returns true if filers have been applied' do
      page_state = described_class.new(params: params, provider_user: provider_user)
      expect(page_state.filtered?).to be(true)
    end

    it 'returns false if filters have not been applied' do
      page_state = described_class.new(params: empty_params, provider_user: provider_user)
      expect(page_state.filtered?).to be(false)
    end
  end
end
