module UCASMatches
  class SendResolvedOnUCASEmails
    attr_reader :ucas_match, :at_our_request

    def initialize(ucas_match, at_our_request:)
      @ucas_match = ucas_match
      @at_our_request = at_our_request
    end

    def call
      raise 'The application has not been resolved on UCAS' if !ucas_match.resolved_on_ucas?

      application_choice = ucas_match.application_choices_for_same_course_on_both_services.first

      if at_our_request
        CandidateMailer.ucas_match_resolved_on_ucas_at_our_request_email(application_choice).deliver_later
      else
        CandidateMailer.ucas_match_resolved_on_ucas_email(application_choice).deliver_later
      end

      application_choice.provider.provider_users.each do |provider_user|
        ProviderMailer.ucas_match_resolved_on_ucas_email(provider_user, application_choice).deliver_later
      end
    end
  end
end
