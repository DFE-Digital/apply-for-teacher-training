module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    skip_before_action :redirect_if_setup_required

    def new
      if FeatureFlag.active?('dfe_sign_in_fallback')
        render :authentication_fallback
      end
    end

    def destroy
      dsi_logout_url = dfe_sign_in_user.provider_interface_dsi_logout_url
      DfESignInUser.end_session!(session)
      redirect_to dsi_logout_url
    end

    def sign_in_by_email
      render_404 and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      provider_user = ProviderUser.find_by(email_address: params.dig(:provider_user, :email_address).downcase.strip)

      if provider_user && provider_user.dfe_sign_in_uid.present?
        ProviderInterface::MagicLinkAuthentication.send_token!(provider_user: provider_user)
      end

      redirect_to provider_interface_check_your_email_path
    end

    def check_your_email; end

    def authenticate_with_token
      redirect_to action: :new and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      render_404 and return unless params[:token]

      provider_user = ProviderInterface::MagicLinkAuthentication.get_user_from_token!(token: params[:token])

      # Equivalent to calling DfESignInUser.begin_session!
      session['dfe_sign_in_user'] = {
        'email_address' => provider_user.email_address,
        'dfe_sign_in_uid' => provider_user.dfe_sign_in_uid,
        'first_name' => provider_user.first_name,
        'last_name' => provider_user.last_name,
        'last_active_at' => Time.zone.now,
      }

      provider_user.update!(last_signed_in_at: Time.zone.now)

      redirect_to provider_interface_applications_path
    end

  private

    def default_authenticated_path
      if authorized_for_support_interface?
        support_interface_path
      else
        provider_interface_path
      end
    end

    def authorized_for_support_interface?
      SupportUser.load_from_session(session)
    end
  end
end
