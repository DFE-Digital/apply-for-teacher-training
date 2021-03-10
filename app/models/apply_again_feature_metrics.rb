class ApplyAgainFeatureMetrics
  def success_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    application_forms = ApplicationForm
      .where(
        phase: 'apply_2',
        recruitment_cycle_year: RecruitmentCycle.current_year,
      )
      .joins(:application_choices)
      .joins(
        "inner join (select auditable_id, max(created_at) as status_last_updated_at
          from audits
          where auditable_type = 'ApplicationChoice'
            and action = 'update'
            and audited_changes#>>'{status, 1}' is not null
          group by auditable_id
        ) as status_audits on status_audits.auditable_id = application_choices.id
          and status_last_updated_at between '#{start_time}' and '#{end_time}'",
      )
      .includes(:application_choices)

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
