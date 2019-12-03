module SupportInterface
  class ImpersonationController < SupportInterfaceController
    before_action :disable_on_production

    def impersonate_candidate
      candidate = Candidate.find(params[:candidate_id])
      # bypass_sign_in will not update the database when signing in
      # https://stackoverflow.com/questions/50405133/devise-bypass-sign-in-without-active-for-authentication-callback#50409127
      bypass_sign_in(candidate, scope: :candidate)

      flash[:success] = "You are now signed in as candidate #{candidate.email_address}"
      redirect_to candidate_interface_application_form_path
    end

  private

    def disable_on_production
      return unless HostingEnvironment.production?

      render_404
    end
  end
end
