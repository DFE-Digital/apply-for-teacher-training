module CandidateInterface
  class ApplicationReferencePolicy < ApplicationPolicy
    alias reference record

    def show_cancel_link?
      history = ReferenceHistory.new(reference).all_events
      history.any? { |event| event.name == 'request_sent' }
    end

    def cancel?
      current_application.application_references.feedback_provided.any? ||
        current_application.application_references.feedback_requested.many?
    end
  end
end
