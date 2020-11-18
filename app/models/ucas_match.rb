class UCASMatch < ApplicationRecord
  audited

  belongs_to :candidate

  enum matching_state: {
    matching_data_updated: 'matching_data_updated',
    new_match: 'new_match',
    processed: 'processed',
  }

  enum action_taken: {
    initial_emails_sent: 'initial_emails_sent',
    reminder_emails_sent: 'reminder_emails_sent',
    ucas_withdrawal_requested: 'ucas_withdrawal_requested',
  }

  def action_needed?
    return false if processed?

    return false unless dual_application_or_dual_acceptance?

    return true if ucas_withdrawal_requested?

    return need_to_send_reminder_emails? if initial_emails_sent?

    return need_to_request_withdrawal_from_ucas? if reminder_emails_sent?

    true
  end

  def dual_application_or_dual_acceptance?
    application_for_the_same_course_in_progress_on_both_services? ||
      application_accepted_on_ucas_and_accepted_on_apply?
  end

  def invalid_matching_data?
    !ucas_matched_applications.all?(&:valid_matching_data?)
  end

  def ucas_matched_applications
    matching_data.map do |data|
      UCASMatchedApplication.new(data, recruitment_cycle_year)
    end
  end

  def need_to_send_reminder_emails?
    return false unless initial_emails_sent?

    send_reminder_emails_date = 5.business_days.after(candidate_last_contacted_at).to_date
    Time.zone.today >= send_reminder_emails_date
  end

  def need_to_request_withdrawal_from_ucas?
    return false unless reminder_emails_sent?

    request_withdrawal_from_ucas_date = 10.business_days.after(candidate_last_contacted_at).to_date
    Time.zone.today >= request_withdrawal_from_ucas_date
  end

  def next_action
    if candidate_last_contacted_at.nil?
      :initial_emails_sent
    elsif initial_emails_sent? && need_to_send_reminder_emails?
      :reminder_emails_sent
    elsif reminder_emails_sent? && need_to_request_withdrawal_from_ucas?
      :ucas_withdrawal_requested
    elsif ucas_withdrawal_requested?
      :confirmed_withdrawal_from_ucas
    end
  end

  def last_action
    return nil if action_taken.nil?

    return :confirmed_withdrawal_from_ucas if processed? && ucas_withdrawal_requested?

    action_taken.to_sym
  end

private

  def application_for_the_same_course_in_progress_on_both_services?
    application_for_the_same_course_on_both_services = ucas_matched_applications.select(&:both_scheme?)

    application_for_the_same_course_on_both_services.map(&:application_in_progress_on_ucas?).any? &&
      application_for_the_same_course_on_both_services.map(&:application_in_progress_on_apply?).any?
  end

  def application_accepted_on_ucas_and_accepted_on_apply?
    ucas_matched_applications.map(&:application_accepted_on_ucas?).any? &&
      ucas_matched_applications.map(&:application_accepted_on_apply?).any?
  end
end
