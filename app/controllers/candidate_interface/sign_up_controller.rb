module CandidateInterface
  class SignUpController < CandidateInterfaceController
    skip_before_action :authenticate_candidate!
    before_action :show_pilot_holding_page_if_not_open

    def new
      @sign_up_form = CandidateInterface::SignUpForm.build_from_candidate(Candidate.new)
    end

    def create
      @sign_up_form = CandidateInterface::SignUpForm.new(candidate_sign_up_form_params)
      @candidate = Candidate.find_or_initialize_by(email_address: @sign_up_form.email_address)

      if @candidate.persisted?
        MagicLinkSignIn.call(candidate: @candidate)
        render 'candidate_interface/shared/check_your_email'
      elsif @sign_up_form.save(@candidate)
        MagicLinkSignUp.call(candidate: @candidate)
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
