module CandidateInterface
  class PreviousApplicationsController < CandidateInterfaceController
    def index
      @application_form = current_application
      @candidate = current_candidate
    end

    def show
      @application_choice = application_choice
    end

  private

    def application_choice
      current_candidate
        .application_choices
        .find(params[:id])
    end
  end
end
