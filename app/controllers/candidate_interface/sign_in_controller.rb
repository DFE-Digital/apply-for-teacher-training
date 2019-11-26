module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in

    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.find_by(email_address: candidate_params[:email_address])

      if @candidate.present?
        MagicLinkSignIn.call(candidate: @candidate)
      end

      render 'candidate_interface/shared/check_your_email'
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
