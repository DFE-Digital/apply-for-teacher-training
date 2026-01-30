module CandidateInterface
  class CarryOverController < CandidateInterfaceController
    before_action AlreadyCarriedOverFilter

    def create
      CarryOverApplication.new(current_application).call
      redirect_to candidate_interface_application_choices_path
    end
  end
end
