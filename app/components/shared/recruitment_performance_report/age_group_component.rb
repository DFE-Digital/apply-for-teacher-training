module RecruitmentPerformanceReport
  class AgeGroupComponent < ViewComponent::Base
    attr_reader :provider, :edi_reports, :region, :filter_report_type

    def initialize(provider:, edi_reports:, region:)
      @provider = provider
      @edi_reports = edi_reports
      @region = region
      @filter_report_type = if region == ReportSharedEnums.all_of_england_key
                              'nonprovider_filter'
                            else
                              'nonregion_filter'
                            end
    end

    def render?
      statistics.present?
    end

    def report
      @report ||= edi_reports.find do |edi_report|
        edi_report.category == 'age_group'
      end
    end

    def statistics
      @statistics ||= report&.statistics&.sort_by { |data| data['nonprovider_filter'] }
    end

    def recruited_number(number, proportion)
      if number.nil? && proportion.nil?
        'Not available'
      elsif number.present? && proportion.present?
        "#{number_with_delimiter(number)} (#{number_to_percentage((proportion - 1) * 100, precision: 0)})"
      else
        0
      end
    end

    def recruited_to_date_previous_cycle
      number_with_delimiter(
        statistics['number_of_candidates_accepted_to_same_date_previous_cycle'],
      )
    end

    def regional_report_submitted_to_date(filter_value)
      number = statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch('number_of_candidates_submitted_to_date', nil)

      number_with_delimiter(number) || 'Not available'
    end

    def regional_report_submitted_to_date_previous_cycle(filter_value)
      number = statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch('number_of_candidates_submitted_to_same_date_previous_cycle', nil)

      number_with_delimiter(number) || 'Not available'
    end

    def regional_report_offered_to_date(filter_value)
      number = statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch('number_of_candidates_submitted_to_date', nil)

      number_with_delimiter(number) || 'Not available'
    end

    def regional_report_offered_to_date_previous_cycle(filter_value)
      number = statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch('number_of_candidates_with_offers_to_same_date_previous_cycle', nil)

      number_with_delimiter(number) || 'Not available'
    end

    def regional_report_recruited_to_date(filter_value)
      regional_report_data = statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end

      number = regional_report_data&.fetch('number_of_candidates_accepted_to_date', nil)
      proportion = regional_report_data&.fetch('number_of_candidates_accepted_to_date_as_proportion_of_last_cycle', nil)

      if number.nil? && proportion.nil?
        'Not available'
      elsif number.present? && proportion.present?
        "#{number_with_delimiter(number)} (#{number_to_percentage((proportion - 1) * 100, precision: 0)})"
      else
        0
      end
    end

    def regional_report_recruited_to_date_previous_cycle(filter_value)
      number = statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch('number_of_candidates_accepted_to_same_date_previous_cycle', nil)

      number_with_delimiter(number) || 'Not available'
    end
  end
end
