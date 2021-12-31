module SupportInterface
  class DuplicateCandidateWarningComponent < ViewComponent::Base
    include ViewHelper

    def initialize(candidate:)
      @candidate = candidate
    end

    def render?
      @candidate.submission_blocked? || @candidate.account_locked?
    end
  end
end
