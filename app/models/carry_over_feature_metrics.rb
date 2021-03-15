class CarryOverFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def carry_over_count(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    ApplicationForm
      .joins(
        'INNER JOIN application_forms previous_application_forms ON previous_application_forms.id = application_forms.previous_application_form_id',
      )
      .where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
        'previous_application_forms.recruitment_cycle_year': RecruitmentCycle.previous_year,
      )
      .count
  end
end
