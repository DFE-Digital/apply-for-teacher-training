module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in

    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.find_or_initialize_by(email_address: candidate_params[:email_address])

      if @candidate.persisted?
        MagicLinkSignIn.call(candidate: @candidate)
        render 'candidate_interface/shared/check_your_email'
      elsif @candidate.valid?
        AuthenticationMailer.sign_in_without_account_email(to: @candidate.email_address).deliver_now
        render 'candidate_interface/shared/check_your_email'
      else
        render :new
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
