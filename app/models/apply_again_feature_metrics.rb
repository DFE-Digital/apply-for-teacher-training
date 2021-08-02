class ApplyAgainFeatureMetrics
  include ActionView::Helpers::NumberHelper

  def success_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    success_count = 0.0
    fail_count = 0.0
    application_forms(start_time, end_time).find_each(batch_size: 100) do |application_form|
      if application_form.successful?
        success_count += 1
      elsif application_form.ended_without_success?
        fail_count += 1
      end
    end
    return nil if (fail_count + success_count).zero?

    success_count / (fail_count + success_count)
  end

  def change_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    finder = CandidateInterface::FindChangedApplyAgainApplications.new
    changed = finder.changed_candidate_count(start_time, end_time)
    total = finder.all_candidate_count(start_time, end_time)
    return nil if total.zero?

    changed.to_f / total
  end

  def application_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    not_applied_count = applications_eligible_for_apply_again_not_applied(start_time, end_time)
    applied_count = applications_eligible_for_apply_again_applied(start_time, end_time)

    return nil if (not_applied_count + applied_count).zero?

    applied_count.to_f / (not_applied_count + applied_count)
  end

  def formatted_success_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    format_as_percentage(success_rate(start_time, end_time))
  end

  def formatted_change_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    format_as_percentage(change_rate(start_time, end_time))
  end

  def formatted_application_rate(
    start_time,
    end_time = Time.zone.now.end_of_day
  )
    format_as_percentage(application_rate(start_time, end_time))
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

  def applications_eligible_for_apply_again(start_time, end_time)
    ApplicationForm
      .apply_1
      .joins(:application_choices)
      .where(
        'NOT EXISTS (:pending_or_successful)',
        pending_or_successful: ApplicationChoice
          .select(1)
          .where(
            status: ApplicationStateChange.valid_states - ApplicationStateChange::UNSUCCESSFUL_END_STATES,
          )
          .where('application_choices.application_form_id = application_forms.id'),
      )
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
  end

  def applications_eligible_for_apply_again_not_applied(start_time, end_time)
    applications_eligible_for_apply_again(start_time, end_time)
      .where.not(
        'application_forms.id': ApplicationForm.where.not(
          previous_application_form_id: nil,
        ).pluck(:previous_application_form_id),
      )
      .distinct
      .pluck(:id)
      .count
  end

  def applications_eligible_for_apply_again_applied(start_time, end_time)
    applications_eligible_for_apply_again(start_time, end_time)
      .joins(:subsequent_application_form)
      .distinct
      .pluck(:id)
      .count
  end
end
