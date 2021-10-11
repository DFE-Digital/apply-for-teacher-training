module SupportInterface
  class SendFraudMatchEmail
    attr_reader :fraud_match

    def initialize(fraud_match)
      @fraud_match = fraud_match
    end

    def call
      fraud_match.candidates.each do |candidate|
        CandidateMailer.fraud_match_email(candidate.current_application).deliver_later
      end
    end
  end
end
