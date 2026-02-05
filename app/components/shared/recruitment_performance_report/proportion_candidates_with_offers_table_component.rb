module RecruitmentPerformanceReport
  class ProportionCandidatesWithOffersTableComponent < ViewComponent::Base
    BIG_QUERY_COLUMN_NAMES_MAPPING = {
      this_cycle: 'offer_rate_to_date',
      last_cycle: 'offer_rate_to_same_date_previous_cycle',
    }.freeze

    attr_reader :report_type, :region

    def initialize(provider, provider_statistics, statistics, report_type: :NATIONAL, region: 'all')
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

    def type_of_data
      case report_type
      when :NATIONAL
        t('.national_data')
      when :REGIONAL
        t('.regional_data')
      end
    end
  end
end
