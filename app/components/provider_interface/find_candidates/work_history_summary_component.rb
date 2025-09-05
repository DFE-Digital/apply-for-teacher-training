class ProviderInterface::FindCandidates::WorkHistorySummaryComponent < ApplicationComponent
  attr_accessor :application_form
  delegate :full_time_education?, to: :application_form
  def initialize(application_form)
    @application_form = application_form
  end

  def work_history_with_breaks
    @work_history_with_breaks ||= WorkHistoryWithBreaks.new(application_form, include_unpaid_experience: true)
  end

  def work_history?
    work_history_with_breaks.work_history.any?
  end

  def unpaid_experience?
    work_history_with_breaks.unpaid_work.any?
  end

  def work_history_text
    if !work_history? && full_time_education?
      'No, I have always been in full time education'
    else
      work_history? ? 'Yes' : 'No'
    end
  end

  def unpaid_experience_text
    unpaid_experience? ? 'Yes' : 'No'
  end
end
