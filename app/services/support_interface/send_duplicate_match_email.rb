module SupportInterface
  class SendDuplicateMatchEmail
    attr_reader :candidate

    def initialize(candidate)
      # do we still need this?
      @candidate = candidate
    end

    def call
      CandidateMailer.duplicate_match_email(@candidate.current_application).deliver_later
    end
  end
end
