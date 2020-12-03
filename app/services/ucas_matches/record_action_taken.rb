module UCASMatches
  class RecordActionTaken
    attr_reader :ucas_match, :action_taken

    def initialize(ucas_match, action_taken)
      @ucas_match = ucas_match
      @action_taken = action_taken
    end

    def call
      ucas_match.update!(
        action_taken: action_taken,
        candidate_last_contacted_at: Time.zone.now,
      )
    end
  end
end
