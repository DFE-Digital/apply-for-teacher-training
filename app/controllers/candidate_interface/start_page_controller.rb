module CandidateInterface
  class StartPageController < CandidateInterfaceController
    before_action :redirect_to_application_if_signed_in
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited, if: :candidate_signed_in?
    skip_before_action :authenticate_candidate!
    allow_unauthenticated_access only: %i[create_account_or_sign_in create_account_or_sign_in_handler]

    def create_account_or_sign_in
      @create_account_or_sign_in_form = CreateAccountOrSignInForm.new
    end

    def create_account_or_sign_in_handler
      @create_account_or_sign_in_form = CreateAccountOrSignInForm.new(create_account_or_sign_in_params)
      render :create_account_or_sign_in and return unless @create_account_or_sign_in_form.valid?

      if @create_account_or_sign_in_form.existing_account?
        SignInCandidate.new(@create_account_or_sign_in_form.email, self).call
      else
        redirect_to candidate_interface_sign_up_path(
          providerCode: params[:providerCode],
          courseCode: params[:courseCode],
        )
      end
    end

  private

    def create_account_or_sign_in_params
      strip_whitespace params.require(:candidate_interface_create_account_or_sign_in_form).permit(:existing_account, :email)
    end
  end
end
