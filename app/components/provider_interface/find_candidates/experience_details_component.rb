class ProviderInterface::FindCandidates::ExperienceDetailsComponent < ViewComponent::Base
  attr_accessor :application_form
  include ViewHelper
  def initialize(application_form)
    @application_form = application_form
  end

  def title
    if work_history? && unpaid_experience?
      t('.title.details_work_and_unpaid')
    elsif work_history?
      t('.title.details_work')
    elsif unpaid_experience?
      t('.title.details_unpaid')
    end
  end

  def working_pattern(item)
    return item.working_pattern if item.is_a?(ApplicationVolunteeringExperience)

    item.commitment.humanize
  end

  def work_history?
    work_history_with_breaks.work_history.any?
  end

  def unpaid_experience?
    work_history_with_breaks.unpaid_work.any?
  end

  def unexplained_break?(item)
    item.is_a?(WorkHistoryWithBreaks::BreakPlaceholder)
  end

  def work_or_volunteer_item?(item)
    item.is_a?(ApplicationWorkExperience) || item.is_a?(ApplicationVolunteeringExperience)
  end

  def explained_break?(item)
    item.is_a?(ApplicationWorkHistoryBreak) && item.respond_to?(:reason)
  end

  def break_duration(explained_or_unexplained_break)
    start_date = explained_or_unexplained_break.start_date.end_of_month
    end_date = (explained_or_unexplained_break.end_date || Time.zone.now).beginning_of_month
    number_of_months = ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month)
    format_months_to_years_and_months(number_of_months)
  end

  def work_or_volunteer_duration(work_or_volunteer_item)
    start_date = work_or_volunteer_item.start_date.to_fs(:month_and_year)
    end_date = work_or_volunteer_item.end_date.try(:to_fs, :month_and_year) || t('.present')

    "#{start_date} – #{end_date}"
  end

  def work_history_with_breaks
    @work_history_with_breaks ||= WorkHistoryWithBreaks.new(application_form, include_unpaid_experience: true)
  end
end
