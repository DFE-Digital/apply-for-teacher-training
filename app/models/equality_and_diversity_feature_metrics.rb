class EqualityAndDiversityFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def response_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    success_count = application_forms_with_feedback(start_time, end_time).count.to_f
    fail_count = application_forms_with_no_feedback(start_time, end_time).count.to_f
    return nil if (fail_count + success_count).zero?

    success_count / (fail_count + success_count)
  end

  def formatted_response_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    format_as_percentage(response_rate(start_time, end_time))
  end

private

  def format_as_percentage(ratio)
    return 'n/a' if ratio.nil?

    percentage = number_with_precision(
      100.0 * ratio,
      precision: 1,
      strip_insignificant_zeros: true,
    )
    "#{percentage}%"
  end

  def application_forms_with_feedback(start_time, end_time)
    ApplicationForm
      .where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      .where('application_forms.submitted_at BETWEEN ? AND ?', start_time, end_time)
      .where.not(equality_and_diversity: '')
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
  end

  def application_forms_with_no_feedback(start_time, end_time)
    ApplicationForm
      .where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      .where('application_forms.submitted_at BETWEEN ? AND ?', start_time, end_time)
      .where(equality_and_diversity: nil).or(ApplicationForm.where(equality_and_diversity: ''))
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
  end
end
