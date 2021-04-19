# NOTE: This component is used by both provider and support UIs
class WorkHistoryItemComponent < ViewComponent::Base
  include ViewHelper

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
      explained_absence_title
    else
      unexplained_absence_title
    end
  end

  def details
    return item.details if item.respond_to?(:details)
    return item.reason if item.respond_to?(:reason)
  end

  def working_with_children?
    item.try(:working_with_children?)
  end

  def relevant_skills?
    item.try(:relevant_skills?)
  end

  def organisation
    item.organisation if item.respond_to?(:organisation)
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
    end_date = (item.end_date || Time.zone.now).beginning_of_month
    number_of_months = ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month)
    format_months_to_years_and_months(number_of_months)
  end

  def working_pattern
    return item.working_pattern if item.is_a?(ApplicationVolunteeringExperience)

    item.commitment.humanize
  end

  def explained_absence_title
    "Break (#{formatted_duration})"
  end

  def unexplained_absence_title
    "Unexplained break (#{formatted_duration})"
  end
end
