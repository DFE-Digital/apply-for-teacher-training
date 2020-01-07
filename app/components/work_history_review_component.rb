# Used in Candidate, Support and Provider interface
class WorkHistoryReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
    @application_form = application_form
    @editable = editable
    @heading_level = heading_level
    @show_incomplete = show_incomplete
    @missing_error = missing_error
  end

  def work_experience_rows(work)
    [
      job_row(work),
      type_row(work),
      description_row(work),
      dates_row(work),
    ]
      .compact
  end

  def no_work_experience_rows
    [
      {
        key: 'Explanation of why you’ve been out of the workplace',
        value: @application_form.work_history_explanation,
        action: 'explanation',
        change_path: candidate_interface_work_history_explanation_path,
      },
    ]
  end

  def break_in_work_history_rows
    action_label = t("application_form.work_history.break.#{@application_form.work_history_breaks ? 'change' : 'enter'}_label")

    [
      {
        key: t('application_form.work_history.break.label'),
        value: @application_form.work_history_breaks,
        action: action_label,
        action_path: Rails.application.routes.url_helpers.candidate_interface_work_history_breaks_path,
      },
    ]
  end

  def breaks_in_work_history?
    CheckBreaksInWorkHistory.call(@application_form)
  end

  def show_missing_banner?
    @show_incomplete
  end

private

  attr_reader :application_form

  def job_row(work)
    {
      id: generate_id(work_id: work.id, attribute: 'job'),
      key: 'Job',
      value: [work.role, work.organisation],
      action: 'job',
      change_path: candidate_interface_work_history_edit_path(work.id),
      aria_describedby: generate_aria_describedby(work.id),
    }
  end

  def type_row(work)
    {
      key: 'Type',
      value: work.commitment.dasherize.humanize,
      action: 'type',
      change_path: candidate_interface_work_history_edit_path(work.id),
      aria_describedby: generate_aria_describedby(work.id),
    }
  end

  def description_row(work)
    {
      key: 'Description',
      value: work.details,
      action: 'description',
      change_path: candidate_interface_work_history_edit_path(work.id),
      aria_describedby: generate_aria_describedby(work.id),
    }
  end

  def dates_row(work)
    {
      id: generate_id(work_id: work.id, attribute: 'dates'),
      key: 'Dates',
      value: "#{formatted_start_date(work)} - #{formatted_end_date(work)}",
      action: 'description',
      change_path: candidate_interface_work_history_edit_path(work.id),
      aria_describedby: generate_aria_describedby(work.id),
    }
  end

  def formatted_start_date(work)
    work.start_date.to_s(:month_and_year)
  end

  def formatted_end_date(work)
    return 'Present' if work.end_date.nil?

    work.end_date.to_s(:month_and_year)
  end

  def generate_id(work_id:, attribute:)
    "work-history-#{work_id}-#{attribute}"
  end

  def generate_aria_describedby(work_id)
    [
      generate_id(work_id: work_id, attribute: 'job'),
      generate_id(work_id: work_id, attribute: 'dates'),
    ]
      .join(' ')
  end
end
