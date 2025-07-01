module DataMigrations
  class MigrateFacFiltersToProviderUserFilters
    TIMESTAMP = 20250625094620
    MANUAL_RUN = true

    def change
      attributes = ProviderUser.where.not(find_a_candidate_filters: {}).map do |provider_user|
        {
          provider_user_id: provider_user.id,
          kind: 'find_candidates_all',
          filters: provider_user.find_a_candidate_filters,
        }
      end

      ProviderUserFilter.insert_all(attributes)
    end
  end
end
