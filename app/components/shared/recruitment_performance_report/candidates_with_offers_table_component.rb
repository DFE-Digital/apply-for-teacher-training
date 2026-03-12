module RecruitmentPerformanceReport
  class CandidatesWithOffersTableComponent < ViewComponent::Base
    BIG_QUERY_COLUMN_NAMES_MAPPING = {
      this_cycle: 'number_of_candidates_with_offers_to_date',
      last_cycle: 'number_of_candidates_with_offers_to_same_date_previous_cycle',
      percentage_change: 'number_of_candidates_with_offers_to_date_as_proportion_of_last_cycle',
    }.freeze

    attr_reader :report_type, :region, :recruitment_cycle_year

    def initialize(
      provider,
      provider_statistics,
      statistics,
      report_type: :NATIONAL,
      region: ReportSharedEnums.all_of_england_key,
      recruitment_cycle_year: RecruitmentCycleTimetable.current_year
    )
      @provider = provider
      @report_type = report_type
      @region = region
      @row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
        field_mapping: BIG_QUERY_COLUMN_NAMES_MAPPING,
        provider_statistics:,
        statistics:,
        report_type:,
      )
      @recruitment_cycle_year = recruitment_cycle_year
    end
  end
end
