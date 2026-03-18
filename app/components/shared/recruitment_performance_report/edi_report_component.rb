module RecruitmentPerformanceReport
  class EdiReportComponent < ApplicationComponent
    attr_reader :provider, :edi_reports, :region, :filter_report_type
    Row = Data.define(:subcategory, :stats_for, :cycle, :applied, :offered, :recruited, :percentage_recruited)

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

    def table_headers
      [
        'Applied',
        'Offered',
        'Recruited',
        'Percentage recruited',
      ]
    end

    def rows(data)
      [
        Row.new(
          subcategory: data['subcategory'] || data['nonprovider_filter'],
          stats_for: provider.name,
          cycle: this_cycle_header,
          applied: number_with_delimiter(data['number_of_candidates_submitted_to_date']) || 'Not available',
          offered: number_with_delimiter(data['number_of_candidates_with_offers_to_date']) || 'Not available',
          recruited: number_with_delimiter(data['number_of_candidates_accepted_to_date']) || 'Not available',
          percentage_recruited: provider_percentage(data['recruited_rate_to_date']),
        ),
        Row.new(
          subcategory: data['subcategory'] || data['nonprovider_filter'],
          stats_for: nil,
          cycle: last_cycle_header,
          applied: number_with_delimiter(data['number_of_candidates_submitted_to_same_date_previous_cycle']) || 'Not available',
          offered: number_with_delimiter(data['number_of_candidates_with_offers_to_same_date_previous_cycle']) || 'Not available',
          recruited: number_with_delimiter(data['number_of_candidates_accepted_to_same_date_previous_cycle']) || 'Not available',
          percentage_recruited: provider_percentage(data['recruited_rate_to_same_date_previous_cycle']),
        ),

        Row.new(
          subcategory: data['subcategory'] || data['nonprovider_filter'],
          stats_for: I18n.t("shared.#{@region}"),
          cycle: this_cycle_header,
          applied: regional_report_number(
            data['nonprovider_filter'],
            'number_of_candidates_submitted_to_date',
          ),
          offered: regional_report_number(
            data['nonprovider_filter'],
            'number_of_candidates_with_offers_to_date',
          ),
          recruited: regional_report_number(
            data['nonprovider_filter'],
            'number_of_candidates_accepted_to_date',
          ),

          percentage_recruited: regional_percentage(
            data['nonprovider_filter'],
            'recruited_rate_to_date',
          ),
        ),

        Row.new(
          subcategory: data['subcategory'] || data['nonprovider_filter'],
          stats_for: nil,
          cycle: last_cycle_header,
          applied: regional_report_number(
            data['nonprovider_filter'],
            'number_of_candidates_submitted_to_same_date_previous_cycle',
          ),
          offered: regional_report_number(
            data['nonprovider_filter'],
            'number_of_candidates_with_offers_to_same_date_previous_cycle',
          ),
          recruited: regional_report_number(
            data['nonprovider_filter'],
            'number_of_candidates_accepted_to_same_date_previous_cycle',
          ),
          percentage_recruited: regional_percentage(
            data['nonprovider_filter'],
            'recruited_rate_to_same_date_previous_cycle',
          ),
        ),
      ]
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

    def this_cycle_header
      report.previous_cycle? ? "#{report.recruitment_cycle_year} cycle" : 'This cycle'
    end

    def last_cycle_header
      report.previous_cycle? ? "#{report.recruitment_cycle_year - 1} cycle" : 'Last cycle'
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
