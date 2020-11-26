module UCASMatches
  class SendResolvedOnUCASEmails
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      raise 'The application has not been resolved on UCAS' if !ucas_match.resolved_on_ucas?

      application_choice = ucas_match.application_choices_for_same_course_on_both_services.first

      CandidateMailer.ucas_match_resolved_on_ucas_email(application_choice).deliver_later

      NotificationsList.for(application_choice).each do |provider_user|
        ProviderMailer.ucas_match_resolved_on_ucas_email(provider_user, application_choice).deliver_later
      end
    end
  end
end
