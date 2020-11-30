module SupportInterface
  class SendUCASMatchInitialEmails
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      return SupportInterface::SendUCASMatchInitialEmailsMultipleAcceptances.new(ucas_match).call if ucas_match.application_accepted_on_ucas_and_accepted_on_apply?

      SupportInterface::SendUCASMatchInitialEmailsDuplicateApplications.new(ucas_match).call if ucas_match.dual_application_or_dual_acceptance?
    end
  end
end
