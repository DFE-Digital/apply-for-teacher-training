module CandidateInterface
  class SignInController < CandidateInterfaceController
    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.find_by(email_address: candidate_params[:email_address])

      if @candidate.present?
        # create the magic link and send the email
        # MagicLinkSignUp.call(candidate: @candidate)

        AuthenticationMailer.sign_in_email(to: @candidate.email_address, token: '1234567890').deliver!
      end

      render :show
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
