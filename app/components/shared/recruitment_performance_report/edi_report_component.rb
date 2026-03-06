module RecruitmentPerformanceReport
  class EdiReportComponent < ViewComponent::Base
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

    def regional_edi_report
      @regional_edi_report ||= Publications::RegionalEdiReport.where(
        region:,
        category: report.category,
        cycle_week: report.cycle_week,
        recruitment_cycle_year: report.recruitment_cycle_year,
      ).order(created_at: :desc).first
    end

    def render?
      serialized_statistics.present? && regional_edi_report.present?
    end

    def title
      raise 'Need to define a report title in your component'
    end

    def report
      raise 'Need to define a report in your component'
    end

    def serialized_statistics
      @serialized_statistics ||= report&.statistics&.sort_by { |data| data['nonprovider_filter'] }
    end

    def provider_percentage(proportion)
      if proportion.nil?
        'Not available'
      else
        number_to_percentage(proportion * 100, precision: 0)
      end
    end

    def provider_report_number(stat)
      number_with_delimiter(stat) || 'Not available'
    end

    def regional_report_number(filter_value, stat)
      number = regional_edi_report&.statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch(stat, nil)

      number_with_delimiter(number) || 'Not available'
    end

    def regional_percentage(filter_value, stat)
      proportion = regional_edi_report&.statistics&.find do |statistic|
        statistic[filter_report_type] == filter_value
      end&.fetch(stat, nil)

      if proportion.nil?
        'Not available'
      else
        number_to_percentage(proportion * 100, precision: 0)
      end
    end
  end
end
