module ProviderInterface
  module RecruitmentPerformanceReport
    class CandidatesWithOffersTableComponent < ApplicationComponent
      BIG_QUERY_COLUMN_NAMES_MAPPING = {
        this_cycle: 'number_of_candidates_with_offers_to_date',
        last_cycle: 'number_of_candidates_with_offers_to_same_date_previous_cycle',
        percentage_change: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle',
      }.freeze

      def initialize(provider, provider_statistics, national_statistics)
        @provider = provider
        @row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
          field_mapping: BIG_QUERY_COLUMN_NAMES_MAPPING,
          provider_statistics:,
          national_statistics:,
        )
      end
    end
  end
end
