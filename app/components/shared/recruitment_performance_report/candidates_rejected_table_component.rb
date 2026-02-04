module RecruitmentPerformanceReport
  class CandidatesRejectedTableComponent < ViewComponent::Base
    BIG_QUERY_COLUMN_NAMES_MAPPING = {
      this_cycle: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date',
      last_cycle: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_same_date_previous_cycle',
      percentage_change: 'number_of_candidates_who_had_all_applications_rejected_this_cycle_to_date_as_proportion_of_last_cycle',
    }.freeze

    attr_reader :type, :region

    def initialize(provider, provider_statistics, statistics, type: :NATIONAL, region: 'all')
      @provider = provider
      @type = type
      @region = region
      @row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
        field_mapping: BIG_QUERY_COLUMN_NAMES_MAPPING,
        provider_statistics:,
        statistics:,
        type:,
      )
    end

    def type_of_data
      case type
      when :NATIONAL
        t('.national_data')
      when :REGIONAL
        t('.regional_data')
      end
    end
  end
end
