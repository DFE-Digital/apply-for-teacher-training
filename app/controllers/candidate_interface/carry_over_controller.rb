module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    before_action AlreadyCarriedOverFilter

    def start
      @application_form = current_application
      render 'candidate_interface/carry_over/not_submitted/start'
    end

    def create
      CarryOverApplication.new(current_application).call
      redirect_to candidate_interface_continuous_applications_details_path
    end
  end
end
