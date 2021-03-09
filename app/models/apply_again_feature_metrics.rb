class ApplyAgainFeatureMetrics
  def success_rate(
    start_time,
    end_time = Time.zone.now.beginning_of_day
  )
    application_forms = ApplicationForm
      .where(
        phase: 'apply_2',
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      .includes(:application_choices)

    # TODO: work out how to implement date filter
    success_count = 0.0
    fail_count = 0.0
    application_forms.find_each do |application_form|
      if application_form.successful?
        success_count += 1 
      elsif application_form.ended_without_success?
        fail_count += 1
      end
    end
    return 0 if (fail_count + success_count).zero?

    success_count / (fail_count + success_count)
  end
end
