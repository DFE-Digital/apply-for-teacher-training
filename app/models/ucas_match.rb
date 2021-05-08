class UCASMatch < ApplicationRecord
  audited

  belongs_to :candidate

  enum action_taken: {
    initial_emails_sent: 'initial_emails_sent',
    reminder_emails_sent: 'reminder_emails_sent',
    ucas_withdrawal_requested: 'ucas_withdrawal_requested',
    resolved_on_apply: 'resolved_on_apply',
    resolved_on_ucas: 'resolved_on_ucas',
    manually_resolved: 'manually_resolved',
    no_application_choice: 'no_application_choice',
  }

  def ready_to_resolve?
    action_taken.present? && !action_needed? && !resolved?
  end

  def resolved?
    %w[resolved_on_apply resolved_on_ucas manually_resolved no_application_choice].include?(action_taken)
  end

  def trackable_applicant_key
    ucas_matched_applications.first.trackable_applicant_key
  end

  def action_needed?
    return false if resolved?

    return false unless dual_application_or_dual_acceptance?

    return need_to_send_reminder_emails? if initial_emails_sent?

    return need_to_request_withdrawal_from_ucas? if reminder_emails_sent?

    return false if ucas_withdrawal_requested?

    true
  end

  def dual_application_or_dual_acceptance?
    application_for_the_same_course_in_progress_on_both_services? ||
      application_accepted_on_ucas_and_accepted_on_apply?
  end

  def application_accepted_on_ucas_and_accepted_on_apply?
    ucas_matched_applications.map(&:application_accepted_on_ucas?).any? &&
      ucas_matched_applications.map(&:application_accepted_on_apply?).any?
  end

  def invalid_matching_data?
    !ucas_matched_applications.all?(&:valid_matching_data?)
  end

  def ucas_matched_applications
    @_ucas_matched_applications ||= matching_data.map do |data|
      UCASMatchedApplication.new(data, recruitment_cycle_year)
    end
  end

  def need_to_send_reminder_emails?
    return false unless initial_emails_sent?

    candidate_withdrawal_request_reminder_date = calculate_action_date(:ucas_match_candidate_withdrawal_request_reminder, candidate_last_contacted_at)
    Time.zone.today >= candidate_withdrawal_request_reminder_date
  end

  def need_to_request_withdrawal_from_ucas?
    return false unless reminder_emails_sent?

    ucas_withdrawal_request_date = calculate_action_date(:ucas_match_ucas_withdrawal_request, candidate_last_contacted_at)
    Time.zone.today >= ucas_withdrawal_request_date
  end

  def next_action
    if candidate_last_contacted_at.nil?
      :initial_emails_sent
    elsif initial_emails_sent? && need_to_send_reminder_emails?
      :reminder_emails_sent
    elsif reminder_emails_sent? && need_to_request_withdrawal_from_ucas?
      :ucas_withdrawal_requested
    end
  end

  def requires_manual_action?
    next_action == :ucas_withdrawal_requested
  end

  def last_action
    return nil if action_taken.nil?

    action_taken.to_sym
  end

  def application_choices_for_same_course_on_both_services
    duplicate_course_applications.map(&:application_choice)
  end

  def duplicate_applications_withdrawn_from_ucas?
    duplicate_course_applications.any? && duplicate_course_applications.all?(&:application_withdrawn_on_ucas?)
  end

  def duplicate_applications_withdrawn_from_apply?
    duplicate_course_applications.any? && duplicate_course_applications.all?(&:application_withdrawn_on_apply?)
  end

  def application_for_the_same_course_in_progress_on_both_services?
    duplicate_course_applications.map(&:application_in_progress_on_ucas?).any? &&
      duplicate_course_applications.map(&:application_in_progress_on_apply?).any?
  end

  def calculate_action_date(action, effective_date)
    TimeLimitCalculator.new(rule: action, effective_date: effective_date).call.fetch(:time_in_future).to_date
  end

private

  def duplicate_course_applications
    ucas_matched_applications.select(&:both_scheme?)
  end
end
