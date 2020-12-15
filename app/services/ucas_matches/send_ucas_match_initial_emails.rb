module UCASMatches
  class SendUCASMatchInitialEmails
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      if send_initial_emails
        UCASMatches::RecordActionTaken.new(ucas_match, :initial_emails_sent).call
      end
    end

  private

    def send_initial_emails
      if ucas_match.application_accepted_on_ucas_and_accepted_on_apply?
        UCASMatches::SendUCASMatchInitialEmailsMultipleAcceptances.new(ucas_match).call
      elsif ucas_match.dual_application_or_dual_acceptance?
        UCASMatches::SendUCASMatchInitialEmailsDuplicateApplications.new(ucas_match).call
      end
    end
  end
end
