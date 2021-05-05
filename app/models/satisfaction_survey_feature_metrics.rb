class SatisfactionSurveyFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def response_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    success_count = 0.0
    fail_count = 0.0
    application_forms(start_time, end_time).find_each do |application_form|
      if application_form.feedback_satisfaction_level? || application_form.feedback_suggestions?
        success_count += 1
      else
        fail_count += 1
      end
    end
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

  def application_forms(start_time, end_time)
    ApplicationForm
      .where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      .where('application_forms.submitted_at BETWEEN ? AND ?', start_time, end_time)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
  end
end
