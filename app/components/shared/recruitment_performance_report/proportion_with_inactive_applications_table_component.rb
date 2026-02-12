module RecruitmentPerformanceReport
  class ProportionWithInactiveApplicationsTableComponent < ViewComponent::Base
    BIG_QUERY_COLUMN_NAMES_MAPPING = {
      this_cycle: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates',
      last_cycle: 'number_of_candidates_who_had_an_inactive_application_last_cycle_to_date_as_proportion_of_submitted_candidates_last_cycle',
    }.freeze

    attr_reader :report_type, :region

    def initialize(
      provider,
      provider_statistics,
      statistics,
      report_type: :NATIONAL,
      region: Publications::RegionalRecruitmentPerformanceReport.all_of_england_key
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
    end
  end
end
