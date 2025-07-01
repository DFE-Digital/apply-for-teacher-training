require 'rails_helper'

RSpec.describe DataMigrations::MigrateFacFiltersToProviderUserFilters do
  describe '#change' do
    it 'migrates the filters from provider_user to provider_user_filters' do
      location_filter = { 'location' => 'Manchester' }
      user_with_filters_1 = create(
        :provider_user,
        find_a_candidate_filters: location_filter,
      )

      location_and_subject_filter = { 'location' => 'Manchester', 'subject_ids' => [1] }
      user_with_filters_2 = create(
        :provider_user,
        find_a_candidate_filters: location_and_subject_filter,
      )
      _user_without_filters = create(:provider_user, find_a_candidate_filters: {})

      expect { described_class.new.change }.to change { ProviderUserFilter.count }.from(0).to(2)
        .and change { user_with_filters_1.provider_user_filters.find_candidates_all.last&.filters }.from(nil).to(location_filter)
        .and change { user_with_filters_2.provider_user_filters.find_candidates_all.last&.filters }.from(nil).to(location_and_subject_filter)
    end
  end
end
