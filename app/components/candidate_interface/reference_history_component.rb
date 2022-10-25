module CandidateInterface
  class ReferenceHistoryComponent < ViewComponent::Base
    attr_reader :reference

    def initialize(reference)
      @reference = reference
    end

    def history
      ReferenceHistory.new(reference).all_events
    end

    def formatted_title(event)
      if event.name == 'request_bounced'
        "The request did not reach #{event.extra_info.bounced_email}"
      elsif event.name == 'request_sent'
        'Request sent'
      elsif event.name == 'reference_received'
        'Reference sent to provider'
      else
        event.name.humanize
      end
    end

    def can_be_cancelled?(event)
      reference.feedback_status == 'feedback_requested' && event.name == 'request_sent'
    end
  end
end
