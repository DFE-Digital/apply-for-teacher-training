module SupportInterface
  class SendDuplicateMatchEmail
    attr_reader :candidate

    def initialize(candidate)
      @candidate = candidate
    end

    def call
      CandidateMailer.fraud_match_email(@candidate.current_application).deliver_later
    end
  end
end
