class WorkHistoryAndUnpaidExperienceComponent < WorkHistoryComponent
  def initialize(application_form:, editable: false, application_choice: nil, details: true, find_candidates: false)
    @application_form = application_form
    @work_history_with_breaks ||= WorkHistoryWithBreaks.new(
      application_choice || application_form,
      include_unpaid_experience: true,
    )
    @editable = editable
    @details = details
    @find_candidates = find_candidates
  end

  def subtitle
    if work_history? && unpaid_experience?
      'Details of work history and unpaid experience'
    elsif work_history?
      'Details of work history'
    elsif unpaid_experience?
      'Details of unpaid experience'
    end
  end

  def render?
    true
  end

private

  def rows
    {
      'Do you have any work history' => work_history_text,
      'Do you have any unpaid experience' => unpaid_experience_text,
    }
  end

  def work_history_text
    if !work_history? && full_time_education?
      ' No, I have always been in full time education'
    else
      work_history? ? 'Yes' : 'No'
    end
  end

  def unpaid_experience_text
    unpaid_experience? ? 'Yes' : 'No'
  end

  delegate :full_time_education?, to: :application_form

  def work_history?
    work_history_with_breaks.work_history.any?
  end

  def unpaid_experience?
    work_history_with_breaks.unpaid_work.any?
  end
end
