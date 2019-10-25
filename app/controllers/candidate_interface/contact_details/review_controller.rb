module CandidateInterface
  class ContactDetails::ReviewController < CandidateInterfaceController
    def show
      @application_form = current_candidate.current_application
    end
  end
end
