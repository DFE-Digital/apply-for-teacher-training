module UCASMatches
  class ResolveOnUCAS
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      UCASMatches::RecordActionTaken.new(ucas_match, :resolved_on_ucas).call
      UCASMatches::SendResolvedOnUCASEmails.new(
        ucas_match,
        at_our_request: ucas_match.action_taken_before_last_save == 'ucas_withdrawal_requested',
      ).call
    end
  end
end
