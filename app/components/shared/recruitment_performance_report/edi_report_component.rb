module RecruitmentPerformanceReport
  class EdiReportComponent < ViewComponent::Base
    attr_reader :provider, :edi_reports, :region, :recruitment_cycle_year,
                :filter_report_type

    def initialize(provider:, edi_reports:, region:, recruitment_cycle_year: nil)
      @provider = provider
      @edi_reports = edi_reports
      @region = region
      @recruitment_cycle_year = recruitment_cycle_year
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
      ).order(created_at: :desc).first
    end

    def render?
      statistics.present?
    end

    def report
      raise 'Need to define a report in your component'
    end

    def statistics
      @statistics ||= report&.statistics&.sort_by { |data| data['nonprovider_filter'] }
    end

    def provider_percentage(proportion)
      if proportion.nil?
        'Not available'
      else
        number_to_percentage(proportion * 100, precision: 0)
      end
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
