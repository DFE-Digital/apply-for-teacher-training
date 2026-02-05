module RecruitmentPerformanceReport
  class DeferralsTableComponent < ViewComponent::Base
    BIG_QUERY_COLUMN_NAMES_MAPPING = {
      this_cycle: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_date',
      last_cycle: 'number_of_candidates_with_reconfirmed_offers_deferred_from_previous_cycle_to_same_date_previous_cycle',
    }.freeze

    def initialize(
      provider,
      provider_statistics,
      statistics,
      report_type: :NATIONAL,
      region: Publications::RegionalRecruitmentPerformanceReport::ALL_REGIONS
    )
      @provider = provider
      @report_type = report_type
      @region = region
      @row_builder = ProviderInterface::Reports::DeferralRowsBuilderService.new(
        field_mapping: BIG_QUERY_COLUMN_NAMES_MAPPING,
        provider_statistics:,
        statistics:,
        report_type:,
      )
    end

    def format_number(row, column_name)
      number = row.send(column_name)
      # We show nil as 'Not available'
      return t('shared.not_available') if number.nil?

      number_with_delimiter(number)
    end

    def provider_name
      @provider.name
    end

    delegate :deferral_rows, to: :@row_builder
  end
end
