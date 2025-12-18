module RecruitmentPerformanceReport
  class ProportionCandidatesWithOffersTableComponent < ViewComponent::Base
    BIG_QUERY_COLUMN_NAMES_MAPPING = {
      this_cycle: 'offer_rate_to_date',
      last_cycle: 'offer_rate_to_same_date_previous_cycle',
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
