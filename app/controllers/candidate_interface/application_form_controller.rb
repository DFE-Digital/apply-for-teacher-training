module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show
      redirect_to candidate_interface_application_form_path if params[:token]
    end
  end
end
