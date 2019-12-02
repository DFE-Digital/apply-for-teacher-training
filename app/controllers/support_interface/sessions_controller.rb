module SupportInterface
  class SessionsController < SupportInterfaceController
    skip_before_action :authenticate_support_user!
    protect_from_forgery except: :bypass_callback

    def new; end

    def callback
      # TODO: Work out whether this conflicts with provider sign-in (is
      # there a use case for having both sign-ins at once even if only
      # for developers doing testing?)
      dfe_sign_in_session = DfESignIn.parse_auth_hash(request.env['omniauth.auth'])
      SupportUser.begin_session!(session, dfe_sign_in_session)

      redirect_to support_interface_path
    end

    def destroy
      SupportUser.end_session!(session)

      redirect_to action: :new
    end

    alias :bypass_callback :callback
  end
end
