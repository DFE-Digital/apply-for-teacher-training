module CandidateInterface
  class Volunteering::ReviewController < CandidateInterfaceController
    def show
      @application_form = current_application
    end
  end
end
