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
    let(:headings) { filter.filters.map { |f| f[:heading] } }
    let(:params) { ActionController::Parameters.new }

    context 'default filters' do
      context 'for a user balonging to multiple providers' do
        let(:filter) do
          described_class.new(params: params,
                              provider_user: provider_user,
                              state_store: {})
        end

        it 'does not include the Locations filter' do
          expected_number_of_filters = 5
          recruitment_cycle_index = 1
          providers_array_index = 3
          number_of_courses = 2

          expect(filter.filters).to be_a(Array)
          expect(filter.filters.size).to eq(expected_number_of_filters)
          expect(filter.filters[recruitment_cycle_index][:options].size).to eq(2)
          expect(filter.filters[providers_array_index][:options].size).to eq(number_of_courses)
          expect(headings).not_to include('Locations')
        end
      end

      context 'for a user belonging to a single provider' do
        let(:filter) do
          described_class.new(params: params,
                              provider_user: another_provider_user,
                              state_store: {})
        end

        it 'does not include the Providers filter' do
          expected_number_of_filters = 5

          expect(filter.filters.size).to eq(expected_number_of_filters)
          expect(headings).not_to include('Provider')
        end
      end
    end

    describe 'location filter' do
      context 'when the user belongs to a single provider ' do
        let(:filter) do
          described_class.new(params: params,
                              provider_user: another_provider_user,
                              state_store: {})
        end

        it 'displays the location filter by default' do
          relevant_provider_ids = [provider1.sites.first.id, provider1.sites.last.id]
          relevant_provider_names = [provider1.sites.first.name, provider1.sites.last.name]

          expect(headings).to include("Locations for #{provider1.name}")
          expect(relevant_provider_ids).to include(filter.filters[4][:options][0][:value])
          expect(relevant_provider_ids).to include(filter.filters[4][:options][1][:value])

          expect(relevant_provider_names).to include(filter.filters[4][:options][0][:label])
          expect(relevant_provider_names).to include(filter.filters[4][:options][1][:label])
        end
      end
    end

    context 'when the user belongs to multiple providers and a provider is selected' do
      let(:params) { ActionController::Parameters.new({ provider: [provider1.id] }) }
      let(:filter) do
        described_class.new(params: params,
                            provider_user: provider_user,
                            state_store: {})
      end

      it 'can return filter config for a list of provider locations' do
        relevant_provider_ids = [provider1.sites.first.id, provider1.sites.last.id]
        relevant_provider_names = [provider1.sites.first.name, provider1.sites.last.name]

        expect(headings).to include("Locations for #{provider1.name}")

        expect(relevant_provider_ids).to include(filter.filters[5][:options][0][:value])
        expect(relevant_provider_ids).to include(filter.filters[5][:options][1][:value])

        expect(relevant_provider_names).to include(filter.filters[5][:options][0][:label])
        expect(relevant_provider_names).to include(filter.filters[5][:options][1][:label])
      end
    end

    context 'when a subject is selected' do
      let(:params) { ActionController::Parameters.new({ subject: provider_1_subjects }) }
      let(:filter) do
        described_class.new(params: params,
                            provider_user: provider_user,
                            state_store: {})
      end

      it 'can return filter config for a list of provider subjects' do
        subjects = provider_1_subjects + provider_2_subjects
        filter_subjects = filter.filters[4][:options].map { |h| h[:label] }

        expect(headings).to include('Subject')
        expect(filter_subjects).to match_array(subjects.map(&:name))
      end
    end
  end

  describe '#applied_filters' do
    let(:params) do
      ActionController::Parameters.new({ status: %w[awaiting_provider_decision pending_conditions recruited declined],
                                         weekdays: %w[wed thurs mon] })
    end
    let(:filter) do
      described_class.new(params: params,
                          provider_user: provider_user,
                          state_store: {})
    end

    it 'returns a has of permitted parameters' do
      expect(filter.applied_filters).to be_a(Hash)
      expect(filter.applied_filters.keys).to include('status')
      expect(filter.applied_filters.keys).not_to include('weekdays')
    end
  end

  describe '#filtered?' do
    let(:filter) do
      described_class.new(params: params,
                          provider_user: provider_user,
                          state_store: {})
    end

    context 'when filters' do
      let(:params) do
        ActionController::Parameters.new({ status: %w[awaiting_provider_decision pending_conditions recruited declined] })
      end

      it 'returns true' do
        expect(filter.filtered?).to eq(true)
      end
    end

    context 'when no filters' do
      let(:params) { ActionController::Parameters.new }

      it 'returns false' do
        filter = described_class.new(params: params, provider_user: provider_user, state_store: {})
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
  end

  describe '#no_results_message' do
    context 'when text search' do
      let(:params) { ActionController::Parameters.new({ candidate_name: 'Tom' }) }
      let(:filter) do
        described_class.new(params: params,
                            provider_user: provider_user,
                            state_store: {})
      end

      it 'returns a relevant message' do
        expect(filter.no_results_message).to eq("There are no results for 'Tom'.")
      end
    end

    context 'when status search' do
      let(:params) { ActionController::Parameters.new({ status: %w[rejected] }) }
      let(:filter) do
        described_class.new(params: params,
                            provider_user: provider_user,
                            state_store: {})
      end

      it 'returns a relevant message' do
        expect(filter.no_results_message).to eq('There are no results for the selected filter.')
      end
    end

    context 'when combined filtering' do
      let(:params) { ActionController::Parameters.new({ candidate_name: 'Tom', status: %w[rejected] }) }
      let(:filter) do
        described_class.new(params: params,
                            provider_user: provider_user,
                            state_store: {})
      end

      it 'returns a relevant message' do
        expect(filter.no_results_message).to eq("There are no results for 'Tom' and the selected filter.")
      end
    end
  end
end
