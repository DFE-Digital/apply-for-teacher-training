module SupportInterface
  class SessionsController < SupportInterfaceController
    skip_before_action :authenticate_support_user!

    def new
      session['post_dfe_sign_in_path'] ||= support_interface_path
    end

    def destroy
      DfESignInUser.end_session!(session)

      redirect_to action: :new
    end
  end
end
