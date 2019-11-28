module CandidateInterface
  class DecisionsController < CandidateInterfaceController
    before_action :set_application_choice

    def offer; end

    def withdraw; end

  private

    def set_application_choice
      @application_choice = current_candidate.current_application.application_choices.find(params[:id])
    end
  end
end
