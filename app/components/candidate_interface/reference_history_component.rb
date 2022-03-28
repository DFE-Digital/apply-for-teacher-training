module CandidateInterface
  class ReferenceHistoryComponent < ViewComponent::Base
    attr_reader :reference

    def initialize(reference)
      @reference = reference
    end

    def history
      ReferenceHistory.new(reference).all_events
    end

    def formatted_date(event)
      event.time.to_fs(:govuk_date_and_time)
    end

    def formatted_title(event)
      if event.name == 'request_bounced'
        "The request did not reach #{event.extra_info.bounced_email}"
      elsif event.name == 'request_sent'
        "Request sent to #{event.extra_info.email_address}"
      else
        event.name.humanize
      end
    end
  end
end
