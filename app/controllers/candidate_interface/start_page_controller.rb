module CandidateInterface
  class StartPageController < CandidateInterfaceController
    before_action :show_pilot_holding_page_if_not_open
    skip_before_action :authenticate_candidate!

    def show; end

    def create_account_or_sign_in
      @create_account_or_sign_in_form = CreateAccountOrSignInForm.new
    end

    def create_account_or_sign_in_handler
      @create_account_or_sign_in_form = CreateAccountOrSignInForm.new(create_account_or_sign_in_params)
      render :create_account_or_sign_in and return unless @create_account_or_sign_in_form.valid?

      if @create_account_or_sign_in_form.existing_account?
        SignInCandidate.new(@create_account_or_sign_in_form.email, self).call
      else
        redirect_to candidate_interface_eligibility_path(
          providerCode: params[:providerCode],
          courseCode: params[:courseCode],
        )
      end
    end

    def eligibility
      @eligibility_form = EligibilityForm.new
    end

    def determine_eligibility
      @eligibility_form = EligibilityForm.new(eligibility_params)

      if !@eligibility_form.valid?
        render :eligibility
      elsif @eligibility_form.eligible_to_use_dfe_apply?
        redirect_to candidate_interface_sign_up_path(providerCode: params[:providerCode], courseCode: params[:courseCode])
      else
        redirect_to candidate_interface_not_eligible_path
      end
    end

    def eligibility_params
      params.fetch(:candidate_interface_eligibility_form, {}).permit(:eligible_citizen, :eligible_qualifications)
        .transform_values(&:strip)
    end

  private

    def create_account_or_sign_in_params
      params.require(:candidate_interface_create_account_or_sign_in_form).permit(:existing_account, :email)
    end
  end
end
