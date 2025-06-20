require 'rails_helper'

RSpec.describe ProviderInterface::ProviderApplicationsFilter do
  let(:provider_1_subjects) { create_list(:subject, 2) }
  let(:provider_2_subjects) { create_list(:subject, 1) }
  let(:provider_3_subjects) { create_list(:subject, 1) }
  let(:accredited_provider_subjects) { create_list(:subject, 1) }

  let(:course1) { create(:course, subjects: provider_1_subjects, study_mode: 'part_time') }
  let(:course2) { create(:course, subjects: provider_2_subjects) }
  let(:course3) { create(:course, subjects: provider_3_subjects) }
  let(:accredited_course) { create(:course, subjects: accredited_provider_subjects, accredited_provider:) }

  let(:site1) { create(:site, provider: provider1) }
  let(:site2) { create(:site, provider: provider1) }
  let!(:course_option) { create(:course_option, course: course1, site: site1) }
  let!(:course_option2) { create(:course_option, course: course1, site: site2) }

  let(:provider1) { create(:provider, courses: [course1]) }
  let(:provider2) { create(:provider, courses: [course2]) }
  let(:provider3) { create(:provider, courses: [course3]) }
  let(:accredited_provider) { create(:provider) }

  let(:provider_user) { create(:provider_user, providers: [provider1, provider2, accredited_provider]) }
  let(:another_provider_user) { create(:provider_user, providers: [provider1]) }
  let(:state_store) do
    StateStores::RedisStore.new(key: "#{described_class::STATE_STORE_KEY}_#{provider_user.id}")
  end

  describe '#filters' do
    let(:headings) { filter.filters.map { |f| f[:heading] } }
    let(:params) { ActionController::Parameters.new }

    context 'default filters' do
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      context 'for a user belonging to multiple providers' do
        let(:filter) do
          described_class.new(params:,
                              provider_user:,
                              state_store:)
        end

        it 'does not include the Locations filter' do
          expected_number_of_filters = 8
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
          described_class.new(params:,
                              provider_user: another_provider_user,
                              state_store:)
        end

        it 'does not include the Providers filter' do
          expected_number_of_filters = 8

          expect(filter.filters.size).to eq(expected_number_of_filters)
          expect(headings).not_to include('Provider')
        end
      end

      it 'does include the course type filter' do
        expect(filter.filters.size).to be(8)
        expect(headings).to include('Course type')
      end
    end

    describe 'location filter' do
      context 'when the user belongs to a single provider' do
        let(:filter) do
          described_class.new(params:,
                              provider_user: another_provider_user,
                              state_store:)
        end

        it 'displays the location filter by default' do
          relevant_provider_name_and_code = ["#{provider1.sites.first.provider_id}_#{provider1.sites.first.name}_#{provider1.sites.first.code}", "#{provider1.sites.last.provider_id}_#{provider1.sites.last.name}_#{provider1.sites.last.code}"]
          relevant_provider_labels = [provider1.sites.first.name_and_code, provider1.sites.last.name_and_code]

          expect(headings).to include("Locations for #{provider1.name}")
          expect(relevant_provider_name_and_code).to include(filter.filters[7][:options][0][:value])
          expect(relevant_provider_name_and_code).to include(filter.filters[7][:options][1][:value])

          expect(relevant_provider_labels).to include(filter.filters[7][:options][0][:label])
          expect(relevant_provider_labels).to include(filter.filters[7][:options][1][:label])
        end
      end

      context 'when a site belongs to an old cycle year' do
        let(:filter) do
          described_class.new(params:,
                              provider_user: another_provider_user,
                              state_store:)
        end

        let(:old_site) { create(:site, provider: provider1) }

        it 'does not appear as an option' do
          old_site_name_and_code = "#{old_site.name}_#{old_site.code}"
          old_site_label = old_site.name_and_code

          expect(headings).to include("Locations for #{provider1.name}")
          expect(old_site_name_and_code).not_to include(filter.filters[7][:options][0][:value])
          expect(old_site_label).not_to include(filter.filters[7][:options][0][:label])
        end
      end
    end

    context 'when the user belongs to multiple providers and a provider is selected' do
      let(:params) { ActionController::Parameters.new({ provider: [provider1.id] }) }
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      it 'can return filter config for a list of provider locations' do
        relevant_provider_name_and_code = ["#{provider1.sites.first.provider_id}_#{provider1.sites.first.name}_#{provider1.sites.first.code}", "#{provider1.sites.last.provider_id}_#{provider1.sites.last.name}_#{provider1.sites.last.code}"]
        relevant_provider_labels = [provider1.sites.first.name_and_code, provider1.sites.last.name_and_code]

        expect(headings).to include("Locations for #{provider1.name}")

        expect(relevant_provider_name_and_code).to include(filter.filters[8][:options][0][:value])
        expect(relevant_provider_name_and_code).to include(filter.filters[8][:options][1][:value])

        expect(relevant_provider_labels).to include(filter.filters[8][:options][0][:label])
        expect(relevant_provider_labels).to include(filter.filters[8][:options][1][:label])
      end
    end

    context 'when a subject is selected' do
      let(:params) { ActionController::Parameters.new({ subject: provider_1_subjects }) }
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      it 'can return filter config for a list of provider subjects' do
        subjects = provider_1_subjects + provider_2_subjects
        filter_subjects = filter.filters[4][:options].map { |h| h[:label] }

        expect(headings).to include('Subject')
        expect(filter_subjects).to match_array(subjects.map(&:name))
      end
    end

    context 'when a study mode is selected' do
      let(:params) { ActionController::Parameters.new }
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      it 'can return a filter config for a list of study modes' do
        study_modes = %w[full_time part_time]
        filter_study_modes = filter.filters[5][:options].map { |h| h[:value] }

        expect(headings).to include('Full time or part time')
        expect(filter_study_modes).to match_array(study_modes)
      end
    end
  end

  describe '#applied_filters' do
    let(:params) do
      ActionController::Parameters.new({ status: %w[awaiting_provider_decision pending_conditions recruited declined],
                                         weekdays: %w[wed thurs mon] })
    end
    let(:filter) do
      described_class.new(params:,
                          provider_user:,
                          state_store:)
    end

    it 'returns a has of permitted parameters' do
      expect(filter.applied_filters).to be_a(Hash)
      expect(filter.applied_filters.keys).to include('status')
      expect(filter.applied_filters.keys).not_to include('weekdays')
    end
  end

  describe '#filtered?' do
    let(:filter) do
      described_class.new(params:,
                          provider_user:,
                          state_store:)
    end

    context 'when filters' do
      let(:params) do
        ActionController::Parameters.new({ status: %w[awaiting_provider_decision pending_conditions recruited declined] })
      end

      it 'returns true' do
        expect(filter.filtered?).to be(true)
      end
    end

    context 'when no filters' do
      let(:params) { ActionController::Parameters.new }

      it 'returns false' do
        filter = described_class.new(params:, provider_user:, state_store:)
        expect(filter.filtered?).to be(false)
      end
    end

    it 'can load and persist its own state' do
      state_one = described_class.new(
        params: ActionController::Parameters.new({ 'candidate_name' => 'Tom Thumb' }),
        provider_user:,
        state_store:,
      )

      # The state is what we passed in
      expect(state_one.applied_filters).to eq({ 'candidate_name' => 'Tom Thumb' })

      state_two = described_class.new(
        params: ActionController::Parameters.new, # empty params
        provider_user:,
        state_store:,
      )

      # The state is kept from last time
      expect(state_two.applied_filters).to eq({ 'candidate_name' => 'Tom Thumb' })

      state_three = described_class.new(
        params: ActionController::Parameters.new({ 'candidate_name' => 'Another Tom' }),
        provider_user:,
        state_store:,
      )

      # Providing new params replaces the saved state
      expect(state_three.applied_filters).to eq({ 'candidate_name' => 'Another Tom' })
    end
  end

  describe '#no_results_message' do
    context 'when text search' do
      let(:params) { ActionController::Parameters.new({ candidate_name: 'Tom' }) }
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      it 'returns a relevant message' do
        expect(filter.no_results_message).to eq("There are no results for 'Tom'.")
      end
    end

    context 'when status search' do
      let(:params) { ActionController::Parameters.new({ status: %w[rejected] }) }
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      it 'returns a relevant message' do
        expect(filter.no_results_message).to eq('There are no results for the selected filter.')
      end
    end

    context 'when combined filtering' do
      let(:params) { ActionController::Parameters.new({ candidate_name: 'Tom', status: %w[rejected] }) }
      let(:filter) do
        described_class.new(params:,
                            provider_user:,
                            state_store:)
      end

      it 'returns a relevant message' do
        expect(filter.no_results_message).to eq("There are no results for 'Tom' and the selected filter.")
      end
    end
  end
end
