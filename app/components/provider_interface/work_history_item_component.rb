module ProviderInterface
  class WorkHistoryItemComponent < ActionView::Component::Base
    include ViewHelper

    validates :item, presence: true

    def initialize(item:)
      self.item = item
    end

    def dates
      "#{formatted_start_date} - #{formatted_end_date}"
    end

    def title
      if item.respond_to?(:role) && item.respond_to?(:working_pattern)
        "#{item.role} - #{working_pattern}"
      elsif item.respond_to?(:reason)
        item.reason
      else
        unexplained_absence_title
      end
    end

    def properties
      properties = {}
      properties['Employer'] = item.organisation if item.respond_to?(:organisation)
      properties['Description'] = item.details if item.respond_to?(:details)
      properties
    end

  private

    attr_accessor :item

    def formatted_start_date
      item.start_date.to_s(:month_and_year)
    end

    def formatted_end_date
      return 'Present' if item.end_date.nil?

      item.end_date.to_s(:month_and_year)
    end

    def formatted_duration
      start_date = item.start_date.end_of_month
      end_date = (item.end_date.to_datetime || Time.zone.now).beginning_of_month
      number_of_months = ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month)
      format_months_to_years_and_months(number_of_months)
    end

    def working_pattern
      return item.commitment.dasherize.humanize if item.working_pattern.blank?

      "#{item.commitment.dasherize.humanize}\n #{item.working_pattern}"
    end

    def unexplained_absence_title
      "Unexplained break in work history (#{formatted_duration})"
    end
  end
end
