class WorkHistoryFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def average_time_to_complete(
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    times_to_get = time_to_complete(start_time, end_time)
    return 'n/a' if times_to_get.blank?

    number_with_precision(
      times_to_get.sum.to_f / times_to_get.size,
      precision: 1,
      strip_insignificant_zeros: true,
    )
  end

private

  def time_to_complete(start_time, end_time = Time.zone.now)
    applications = ApplicationForm
      .where(
        'application_forms.id IN (:application_form_ids)',
        application_form_ids: Audited::Audit
          .select(:auditable_id)
          .where(auditable_type: 'ApplicationForm')
          .where("audited_changes#>>'{work_history_completed, 1}' = 'true'")
          .where('created_at BETWEEN ? AND ?', start_time, end_time),
      )
    applications.map { |application| time_to_complete_for(application) }.compact
  end

  def time_to_complete_for(application)
    completion_audit = application.audits.where("audited_changes#>>'{work_history_completed, 1}' = 'true'").last
    started_at = (
      application.application_work_history_breaks.pluck(:created_at) +
      application.application_volunteering_experiences.pluck(:created_at) +
      application.application_work_experiences.pluck(:created_at)).min

    (completion_audit.created_at - started_at).to_i / 1.day
  end
end
