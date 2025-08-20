module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    before_action AlreadyCarriedOverFilter

    def start
      redirect_to candidate_interface_application_choices_path
    end

    def create
      CarryOverApplication.new(current_application).call
      redirect_to candidate_interface_details_path
    end
  end
end
