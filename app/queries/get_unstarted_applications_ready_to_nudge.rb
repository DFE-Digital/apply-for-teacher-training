class GetUnstartedApplicationsReadyToNudge
  MAILER = 'candidate_mailer'.freeze
  MAIL_TEMPLATE = 'nudge_unstarted'.freeze
  INACTIVE_FOR_DAYS = 14

  def call
    ApplicationForm
      .unstarted
      .inactive_since(INACTIVE_FOR_DAYS.days.ago)
      .current_cycle
      .has_not_received_email(MAILER, MAIL_TEMPLATE)
  end
end
