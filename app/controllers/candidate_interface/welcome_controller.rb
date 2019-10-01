module CandidateInterface
  class WelcomeController < CandidateInterfaceController
    before_action :authenticate_candidate!

    def show
      redirect_to candidate_interface_welcome_path if params[:token]
    end
  end
end
