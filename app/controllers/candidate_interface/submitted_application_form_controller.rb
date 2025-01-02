module CandidateInterface
  class SubmittedApplicationFormController < CandidateInterfaceController
    def review_submitted
      @application_form = current_application
    end
  end
end
