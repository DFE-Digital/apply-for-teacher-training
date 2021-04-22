module UCASMatches
  class SendUCASMatchInitialEmailsDuplicateApplications
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      raise "Initial emails for UCAS match ##{ucas_match.id} were already sent" if ucas_match.initial_emails_sent?

      application_choice = ucas_match.application_choices_for_same_course_on_both_services.first
      report_bad_data!(ucas_match) if application_choice.blank?

      CandidateMailer.ucas_match_initial_email_duplicate_applications(application_choice).deliver_later

      application_choice.provider.provider_users.each do |provider_user|
        ProviderMailer.ucas_match_initial_email_duplicate_applications(provider_user, application_choice).deliver_later
      end
    end

    def report_bad_data!(ucas_match)
      ucas_match.update!(action_taken: :no_application_choice)
      raise "No application choices found for UCAS match ##{ucas_match.id}"
    end
  end
end
