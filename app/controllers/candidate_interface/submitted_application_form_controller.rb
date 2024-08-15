module CandidateInterface
  class SubmittedApplicationFormController < CandidateInterfaceController
    before_action CarryOverFilter, only: %i[complete]
    before_action AlreadyCarriedOverFilter, only: %i[complete]

    def review_submitted
      @application_form = current_application
    end

    def complete
      @candidate = current_candidate
      @application_form = current_application
    end
  end
end
