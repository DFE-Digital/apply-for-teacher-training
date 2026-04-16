module ProviderInterface
  class UnsubscribeFromEmailsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    skip_before_action :redirect_if_setup_required
    skip_before_action :require_authentication
    skip_before_action :redirect_unless_user_associated_with_an_organisation

    def unsubscribe
      provider_user = ProviderUser.find_by_token_for!(:unsubscribe_link, token_param)
      provider_user.notification_preferences.update!(marketing_emails: false)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      render_404
    end

  private

    def token_param
      params.require(:token)
    end
  end
end
