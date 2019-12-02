module CandidateInterface
  class SignInController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in, except: :authenticate

    def new
      @candidate = Candidate.new
    end

    def create
      @candidate = Candidate.for_email candidate_params[:email_address]

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

    def authenticate
      user = FindCandidateByToken.call(raw_token: params[:token])
      if user
        sign_in(user, scope: :candidate)
        redirect_to candidate_interface_application_form_path
      else
        redirect_to action: :new
      end
    end

  private

    def candidate_params
      params.require(:candidate).permit(:email_address)
    end
  end
end
