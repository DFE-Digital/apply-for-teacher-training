module UCASMatches
  class ResolveOnApply
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      ucas_match.update!(action_taken: 'resolved_on_apply',
                         candidate_last_contacted_at: Time.zone.now)

      UCASMatches::SendResolvedOnApplyEmails.new(ucas_match).call
    end
  end
end
