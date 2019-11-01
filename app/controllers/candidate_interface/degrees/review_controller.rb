module CandidateInterface
  class Degrees::ReviewController < CandidateInterfaceController
    def show
      @application_form = current_candidate.current_application
    end
  end
end
