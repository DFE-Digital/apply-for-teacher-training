class ReferenceFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def average_time_to_get_references(
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    times_to_get = time_to_get_references(start_time, end_time)
    return 'n/a' if times_to_get.blank?

    average_days = number_with_precision(
      times_to_get.sum.to_f / times_to_get.size,
      precision: 1,
      strip_insignificant_zeros: true,
    )
    "#{average_days} #{'day'.pluralize(average_days)}"
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
      .where('"references".feedback_provided_at BETWEEN ? AND ? AND "references".duplicate = ?', start_time, end_time, false)
      .group('application_forms.id')
    applications.map { |application| time_to_get_for(application, end_time) }.compact
  end

  def time_to_get_for(application, end_time)
    return nil unless application.minimum_references_available_for_selection?

    times = application.application_references.feedback_provided.where(duplicate: false).map do |reference|
      [reference.requested_at, reference.feedback_provided_at]
    end
    requested_at_time = times.map(&:first).compact.min
    provided_at_time = times.map(&:second).compact.max
    return nil if requested_at_time.nil? || provided_at_time.nil? || provided_at_time > end_time

    (provided_at_time - requested_at_time) / 1.day
  end
end
