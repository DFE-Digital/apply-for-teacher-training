class QualificationsFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def formatted_a_level_percentage(
    minimum_count,
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    applications_with_a_levels_count = applications_with_a_levels_grouped_counts(
      minimum_count,
      start_time,
      end_time,
    ).keys.count
    all_applications_count = all_applications(start_time, end_time).count

    return 'n/a' if all_applications_count.zero?

    format_as_percentage(applications_with_a_levels_count.to_f / all_applications_count)
  end

private

  def all_applications(start_time, end_time)
    ApplicationForm
      .where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      .where('application_forms.submitted_at BETWEEN ? AND ?', start_time, end_time)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
  end

  def applications_with_a_levels_grouped_counts(minimum_count, start_time, end_time)
    all_applications(start_time, end_time)
      .joins(:application_qualifications)
      .where('application_qualifications.level': 'other')
      .where("application_qualifications.qualification_type IN ('A level', 'A/S level')")
      .having('count(application_qualifications.id) >= ?', minimum_count)
      .group('application_forms.id')
      .count
  end

  def format_as_percentage(ratio)
    return 'n/a' if ratio.nil?

    percentage = number_with_precision(
      100.0 * ratio,
      precision: 1,
      strip_insignificant_zeros: true,
    )
    "#{percentage}%"
  end
end
