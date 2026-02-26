class ProviderEdiReportDecorator < SimpleDelegator
  include ActionView::Helpers::NumberHelper

  attr_reader :region, :filter_report_type

  def initialize(report, region)
    __setobj__(report)
    @region = region
    @filter_report_type = if region == ReportSharedEnums.all_of_england_key
                            'nonprovider_filter'
                          else
                            'nonregion_filter'
                          end
  end

  def ordered_statistics
    @ordered_statistics ||= statistics.sort_by { |data| data['nonprovider_filter'] }
  end

  def regional_report
    @regional_report = Publications::RegionalEdiReport.where(
      region:,
      category:,
      cycle_week:,
    ).order(created_at: :desc).first
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
    number = regional_report&.statistics&.find do |statistic|
      statistic[filter_report_type] == filter_value
    end&.fetch('number_of_candidates_submitted_to_date', nil)

    number_with_delimiter(number) || 'Not available'
  end

  def regional_report_submitted_to_date_previous_cycle(filter_value)
    number = regional_report&.statistics&.find do |statistic|
      statistic[filter_report_type] == filter_value
    end&.fetch('number_of_candidates_submitted_to_same_date_previous_cycle', nil)

    number_with_delimiter(number) || 'Not available'
  end

  def regional_report_offered_to_date(filter_value)
    number = regional_report&.statistics&.find do |statistic|
      statistic[filter_report_type] == filter_value
    end&.fetch('number_of_candidates_submitted_to_date', nil)

    number_with_delimiter(number) || 'Not available'
  end

  def regional_report_offered_to_date_previous_cycle(filter_value)
    number = regional_report&.statistics&.find do |statistic|
      statistic[filter_report_type] == filter_value
    end&.fetch('number_of_candidates_with_offers_to_same_date_previous_cycle', nil)

    number_with_delimiter(number) || 'Not available'
  end

  def regional_report_recruited_to_date(filter_value)
    regional_report_data = regional_report&.statistics&.find do |statistic|
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
    number = regional_report&.statistics&.find do |statistic|
      statistic[filter_report_type] == filter_value
    end&.fetch('number_of_candidates_accepted_to_same_date_previous_cycle', nil)

    number_with_delimiter(number) || 'Not available'
  end

  def disability_category(non_provider_filter)
    Hesa::Disability.find_by_code(non_provider_filter, recruitment_cycle_year)&.value || non_provider_filter
  end
end
