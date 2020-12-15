module UCASMatches
  class ResolveOnApply
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      UCASMatches::RecordActionTaken.new(ucas_match, :resolved_on_apply).call
      UCASMatches::SendResolvedOnApplyEmails.new(ucas_match).call
    end
  end
end
