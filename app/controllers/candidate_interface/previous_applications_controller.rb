module CandidateInterface
  class PreviousApplicationsController < CandidateInterfaceController
    before_action CarryOverFilter, except: :index

    def index
      @application_form = current_application
      @candidate = current_candidate
    end
  end
end
