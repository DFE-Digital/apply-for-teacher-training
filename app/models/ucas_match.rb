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
  }

  def action_needed?
    return false if processed?

    return need_to_send_reminder_emails? if initial_emails_sent?

    application_for_the_same_course_in_progress_on_both_services? ||
      application_accepted_on_ucas_and_in_progress_on_apply? ||
      application_accepted_on_apply_and_in_progress_on_ucas?
  end

  def invalid_matching_data?
    !ucas_matched_applications.all?(&:valid_matching_data?)
  end

  def ucas_matched_applications
    matching_data.map do |data|
      UCASMatchedApplication.new(data, recruitment_cycle_year)
    end
  end

private

  def application_for_the_same_course_in_progress_on_both_services?
    application_for_the_same_course_on_both_services = ucas_matched_applications.select(&:both_scheme?)

    application_for_the_same_course_on_both_services.map(&:application_in_progress_on_ucas?).any? &&
      application_for_the_same_course_on_both_services.map(&:application_in_progress_on_apply?).any?
  end

  def application_accepted_on_ucas_and_in_progress_on_apply?
    ucas_matched_applications.map(&:application_accepted_on_ucas?).any? &&
      ucas_matched_applications.map(&:application_in_progress_on_apply?).any?
  end

  def application_accepted_on_apply_and_in_progress_on_ucas?
    ucas_matched_applications.map(&:application_accepted_on_apply?).any? &&
      ucas_matched_applications.map(&:application_in_progress_on_ucas?).any?
  end

  def need_to_send_reminder_emails?
    return false unless initial_emails_sent?

    send_reminder_emails_date = 5.business_days.after(candidate_last_contacted_at).to_date
    Time.zone.today >= send_reminder_emails_date
  end
end
