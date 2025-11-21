module CandidateInterface
  class ReferenceStatusLineComponent < ReferenceHistoryComponent
    attr_reader :reference

    def request_sent_at
      reference.requested_at
    end

    def can_be_cancelled?
      ApplicationReferencePolicy.new(nil, reference).show_cancel_link?
    end

    def can_send_reminder?
      ReferenceActionsPolicy.new(reference).can_send_reminder? && request_sent_at && request_sent_at <= TimeLimitConfig.minimum_hours_between_chaser_emails.hours.ago
    end
  end
end
