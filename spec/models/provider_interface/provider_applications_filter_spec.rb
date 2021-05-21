require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsFilter do
  let(:provider_1_subjects) { create_list(:subject, 2) }
  let(:provider_2_subjects) { create_list(:subject, 1) }
  let(:provider_3_subjects) { create_list(:subject, 1) }
  let(:accredited_provider_subjects) { create_list(:subject, 1) }

  let(:course1) { create(:course, subjects: provider_1_subjects) }
  let(:course2) { create(:course, subjects: provider_2_subjects) }
  let(:course3) { create(:course, subjects: provider_3_subjects) }
  let(:accredited_course) { create(:course, subjects: accredited_provider_subjects, accredited_provider: accredited_provider) }

  let(:site1) { create(:site) }
  let(:site2) { create(:site) }

  let(:provider1) { create(:provider, courses: [course1], sites: [site1, site2]) }
  let(:provider2) { create(:provider, courses: [course2]) }
  let(:provider3) { create(:provider, courses: [course3]) }
  let(:accredited_provider) { create(:provider) }

  let(:provider_user) { create(:provider_user, providers: [provider1, provider2, accredited_provider]) }
  let(:another_provider_user) { create(:provider_user, providers: [provider1]) }

  describe '#filters' do
    it 'calculates a correct list of possible filters' do
      filter = described_class.new(
        params: ActionController::Parameters.new,
        provider_user: provider_user,
        state_store: {},
      )

      expected_number_of_filters = 5
      recruitment_cycle_index = 1
      providers_array_index = 3
      number_of_courses = 2

      expect(filter.filters).to be_a(Array)
      expect(filter.filters.size).to eq(expected_number_of_filters)
      expect(filter.filters[recruitment_cycle_index][:options].size).to eq(2)
      expect(filter.filters[providers_array_index][:options].size).to eq(number_of_courses)
    end

    it 'does not include providers if available providers is < 2' do
      filter = described_class.new(
        params: ActionController::Parameters.new,
        provider_user: another_provider_user,
        state_store: {},
      )

      expected_number_of_filters = 4

      headings = filter.filters.map { |f| f[:heading] }

      expect(filter.filters.size).to eq(expected_number_of_filters)
      expect(headings).not_to include('Provider')
    end

    it 'can return filter config for a list of provider locations' do
      filter = described_class.new(
        params: ActionController::Parameters.new({ provider: [provider1.id] }),
        provider_user: another_provider_user,
        state_store: {},
      )

      headings = filter.filters.map { |f| f[:heading] }

      expect(headings).to include("Locations for #{provider1.name}")

      relevant_provider_ids = [provider1.sites.first.id, provider1.sites.last.id]
      relevant_provider_names = [provider1.sites.first.name, provider1.sites.last.name]

      expect(relevant_provider_ids).to include(filter.filters[4][:options][0][:value])
      expect(relevant_provider_ids).to include(filter.filters[4][:options][1][:value])

      expect(relevant_provider_names).to include(filter.filters[4][:options][0][:label])
      expect(relevant_provider_names).to include(filter.filters[4][:options][1][:label])
    end

    it 'can return filter config for a list of provider subjects' do
      filter = described_class.new(
        params: ActionController::Parameters.new({ subject: provider_1_subjects }),
        provider_user: provider_user,
        state_store: {},
      )

      headings = filter.filters.map { |f| f[:heading] }
      expect(headings).to include('Subject')

      subjects = provider_1_subjects + provider_2_subjects
      filter_subjects = filter.filters[4][:options].map { |h| h[:label] }

      expect(filter_subjects).to match_array(subjects.map(&:name))
    end
  end

  describe '#applied_filters' do
    let(:params) do
      ActionController::Parameters.new(
        {
          'status' => %w[awaiting_provider_decision pending_conditions recruited declined],
          'weekdays' => %w[wed thurs mon],
        },
      )
    end

    it 'returns a has of permitted parameters' do
      filter = described_class.new(params: params, provider_user: provider_user, state_store: {})

      expect(filter.applied_filters).to be_a(Hash)
      expect(filter.applied_filters.keys).to include('status')
      expect(filter.applied_filters.keys).not_to include('weekdays')
    end
  end

  describe '#filtered?' do
    let(:params) do
      ActionController::Parameters.new({
        'status' => %w[awaiting_provider_decision pending_conditions recruited declined],
      })
    end

    let(:empty_params) { ActionController::Parameters.new }

    it 'returns true if filters have been applied' do
      filter = described_class.new(params: params, provider_user: provider_user, state_store: {})
      expect(filter.filtered?).to eq(true)
    end

    it 'returns false if filters have not been applied' do
      filter = described_class.new(params: empty_params, provider_user: provider_user, state_store: {})
      expect(filter.filtered?).to eq(false)
    end
  end

  it 'can load and persist its own state' do
    state_store = {}

    state_one = described_class.new(
      params: ActionController::Parameters.new({ 'candidate_name' => 'Tom Thumb' }),
      provider_user: provider_user,
      state_store: state_store,
    )

    # The state is what we passed in
    expect(state_one.applied_filters).to eq({ 'candidate_name' => 'Tom Thumb' })

    state_two = described_class.new(
      params: ActionController::Parameters.new, # empty params
      provider_user: provider_user,
      state_store: state_store,
    )

    # The state is kept from last time
    expect(state_two.applied_filters).to eq({ 'candidate_name' => 'Tom Thumb' })

    state_three = described_class.new(
      params: ActionController::Parameters.new({ 'candidate_name' => 'Another Tom' }),
      provider_user: provider_user,
      state_store: state_store,
    )

    # Providing new params replaces the saved state
    expect(state_three.applied_filters).to eq({ 'candidate_name' => 'Another Tom' })
  end

  describe '#no_results_message' do
    it 'returns a message specific to text searches' do
      filter = described_class.new(
        params: ActionController::Parameters.new({ 'candidate_name' => 'Tom' }),
        provider_user: provider_user,
        state_store: {},
      )

      expect(filter.no_results_message).to eq("There are no results for 'Tom'.")
    end

    it 'returns a message specific to filtering' do
      filter = described_class.new(
        params: ActionController::Parameters.new({ 'status' => %w[rejected] }),
        provider_user: provider_user,
        state_store: {},
      )

      expect(filter.no_results_message).to eq('There are no results for the selected filter.')
    end

    it 'returns a message specific to searching combined with filtering' do
      filter = described_class.new(
        params: ActionController::Parameters.new({ 'candidate_name' => 'Tom', 'status' => %w[rejected] }),
        provider_user: provider_user,
        state_store: {},
      )

      expect(filter.no_results_message).to eq("There are no results for 'Tom' and the selected filter.")
    end
  end
end
