class FeatureMetrics
  include ActionView::Helpers::NumberHelper

  def average_time_to_get_references(
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    times_to_get = time_to_get_references(start_time, end_time)
    return 'n/a' if times_to_get.blank?

    number_with_precision(
      times_to_get.sum.to_f / times_to_get.size,
      precision: 1,
      strip_insignificant_zeros: true,
    )
  end

  def percentage_references_within(
    number_of_days,
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    times_to_get = time_to_get_references(start_time, end_time)
    return 'n/a' if times_to_get.blank?

    percentage = number_with_precision(
      times_to_get.select { |days| days <= number_of_days }.size.to_f * 100 / times_to_get.size,
      precision: 1,
      strip_insignificant_zeros: true,
    )
    "#{percentage}%"
  end

private

  def time_to_get_references(start_time, end_time = Time.zone.now)
    applications = ApplicationForm
      .joins(:application_references)
      .where(
        '"references".id IN (:reference_ids)',
        reference_ids: Audited::Audit
          .select(:auditable_id)
          .where(auditable_type: 'ApplicationReference')
          .where("audited_changes#>>'{feedback_status, 1}' = 'feedback_provided'")
          .where('created_at BETWEEN ? AND ?', start_time, end_time),
      )
      .group('application_forms.id')
      .having('count("references".id) = 2')
    applications.map { |application| time_to_get_for(application) }.compact
  end

  def time_to_get_for(application)
    times = application.application_references.feedback_provided.map do |reference|
      provided_audit = reference.audits.where("audited_changes#>>'{feedback_status, 1}' = 'feedback_provided'").last
      [reference.requested_at, provided_audit&.created_at]
    end
    requested_at_times = times.map(&:first)
    provided_at_times = times.map(&:second)
    (provided_at_times.min - requested_at_times.max).to_i / 1.day
  end
end
