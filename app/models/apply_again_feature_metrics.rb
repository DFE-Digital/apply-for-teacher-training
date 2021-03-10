class ApplyAgainFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def success_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    success_count = 0.0
    fail_count = 0.0
    application_forms(start_time, end_time).find_each do |application_form|
      if application_form.successful?
        success_count += 1
      elsif application_form.ended_without_success?
        fail_count += 1
      end
    end
    return nil if (fail_count + success_count).zero?

    success_count / (fail_count + success_count)
  end

  def formatted_success_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    ratio = success_rate(start_time, end_time)
    return 'n/a' if ratio.nil?

    percentage = number_with_precision(
      100.0 * ratio,
      precision: 1,
      strip_insignificant_zeros: true,
    )
    "#{percentage}%"
  end

private

  def application_forms(start_time, end_time)
    ApplicationForm
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
  end
end
