module UCASMatches
  class ResolveOnUCAS
    attr_reader :ucas_match

    def initialize(ucas_match)
      @ucas_match = ucas_match
    end

    def call
      UCASMatches::RecordActionTaken.new(ucas_match, :resolved_on_ucas).call
      UCASMatches::SendResolvedOnUCASEmails.new(ucas_match).call
    end
  end
end
