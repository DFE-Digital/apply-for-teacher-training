module SupportInterface
  class SendUCASMatchReminderEmails
    attr_accessor :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      raise 'Reminder email was already sent' if ucas_match.reminder_emails_sent?

      raise 'Cannot send reminder email before sending an initial one' unless ucas_match.initial_emails_sent?

      # it's impossible for the candiate to have multiple acceptances and duplicate applications
      # we will contact them about dual application in progress before they have a change to accept multiple offers

      return send_duplicate_applications_candidate_reminder_email if ucas_match.application_for_the_same_course_in_progress_on_both_services?

      send_multiple_acceptances_candidate_reminder_email if ucas_match.application_accepted_on_ucas_and_accepted_on_apply?
    end

  private

    def send_multiple_acceptances_candidate_reminder_email
      CandidateMailer.ucas_match_reminder_email_multiple_acceptances(ucas_match).deliver_later
    end

    def send_duplicate_applications_candidate_reminder_email
      ucas_match.application_choices_for_same_course_on_both_services.each do |application_choice|
        CandidateMailer.ucas_match_reminder_email_duplicate_applications(application_choice, ucas_match).deliver_later
      end
    end
  end
end
