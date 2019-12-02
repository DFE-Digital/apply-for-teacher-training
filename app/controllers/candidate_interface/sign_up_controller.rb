module CandidateInterface
  class SignUpController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :redirect_to_application_if_signed_in
    before_action :show_pilot_holding_page_if_not_open

    def new
      @sign_up_form = CandidateInterface::SignUpForm.new
    end

    def create
      @sign_up_form = CandidateInterface::SignUpForm.new(candidate_sign_up_form_params)

      if @sign_up_form.existing_candidate?
        MagicLinkSignIn.call(candidate: @sign_up_form.candidate)
        render 'candidate_interface/shared/check_your_email'
      elsif @sign_up_form.save
        MagicLinkSignUp.call(candidate: @sign_up_form.candidate)
        render 'candidate_interface/shared/check_your_email'
      else
        render :new
      end
    end

    def show; end

  private

    def candidate_sign_up_form_params
      params.require(:candidate_interface_sign_up_form).permit(:email_address, :accept_ts_and_cs)
    end
  end
end
