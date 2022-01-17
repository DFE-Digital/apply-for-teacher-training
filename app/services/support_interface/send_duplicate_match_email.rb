module SupportInterface
  class SendDuplicateMatchEmail
    attr_reader :candidate

    def initialize(candidate)
      @candidate = candidate
    end

    def call
      CandidateMailer.duplicate_match_email(@candidate.current_application, submitted).deliver_later
    end

    def submitted
      @candidate.application_forms.map(&:submitted_at).any?
    end
  end
end
