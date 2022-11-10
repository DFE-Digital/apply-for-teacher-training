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
      I18n.t("candidate_reference_history.#{event.name}", default: event.name.humanize)
    end
  end
end
