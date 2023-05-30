class GetUnstartedApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unstarted'.freeze
  INACTIVE_FOR_DAYS = 14
  IGNORE_EARLIER_THAN = Date.new(2023, 1, 1)

  def call
    ApplicationForm
      .unstarted
      .inactive_since(INACTIVE_FOR_DAYS.days.ago)
      .current_cycle
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
      .where('created_at > ?', IGNORE_EARLIER_THAN)
  end
end
