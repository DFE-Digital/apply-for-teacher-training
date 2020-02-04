class WorkHistoryReviewComponent < ActionView::Component::Base
  validates :application_form, presence: true

  def initialize(application_form:, editable: true, heading_level: 2, show_incomplete: false, missing_error: false)
    @application_form = application_form
    @editable = editable
    @heading_level = heading_level
    @show_incomplete = show_incomplete
    @missing_error = missing_error
    @work_history_with_breaks = WorkHistoryWithBreaks.new(@application_form.application_work_experiences).timeline
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
        action: 'explanation of why you’ve been out of the workplace',
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
      key: 'Job',
      value: [work.role, work.organisation],
      action: generate_action(work: work, attribute: 'job title'),
      change_path: candidate_interface_work_history_edit_path(work.id),
    }
  end

  def type_row(work)
    {
      key: 'Type',
      value: work.commitment.dasherize.humanize,
      action: generate_action(work: work, attribute: 'type'),
      change_path: candidate_interface_work_history_edit_path(work.id),
    }
  end

  def description_row(work)
    {
      key: 'Description',
      value: work.details,
      action: generate_action(work: work, attribute: 'description'),
      change_path: candidate_interface_work_history_edit_path(work.id),
    }
  end

  def dates_row(work)
    {
      key: 'Dates',
      value: "#{formatted_start_date(work)} - #{formatted_end_date(work)}",
      action: generate_action(work: work, attribute: 'dates'),
      change_path: candidate_interface_work_history_edit_path(work.id),
    }
  end

  def formatted_start_date(work)
    work.start_date.to_s(:month_and_year)
  end

  def formatted_end_date(work)
    return 'Present' if work.end_date.nil?

    work.end_date.to_s(:month_and_year)
  end

  def generate_action(work:, attribute: '')
    if any_jobs_with_same_role_and_organisation?(work)
      "#{attribute.presence} for #{work.role}, #{work.organisation}, #{formatted_start_date(work)} to #{formatted_end_date(work)}"
    else
      "#{attribute.presence} for #{work.role}, #{work.organisation}"
    end
  end

  def any_jobs_with_same_role_and_organisation?(work)
    jobs = @application_form.application_work_experiences.where(role: work.role, organisation: work.organisation)
    jobs.many?
  end
end
