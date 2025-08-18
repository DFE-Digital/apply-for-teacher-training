module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    before_action AlreadyCarriedOverFilter

    def start
      @application_form = current_application
    end

    def create
      CarryOverApplication.new(current_application).call
      redirect_to candidate_interface_details_path
    end
  end
end
