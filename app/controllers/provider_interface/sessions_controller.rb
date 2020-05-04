module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    skip_before_action :check_data_sharing_agreements

    def new
      if FeatureFlag.active?('dfe_sign_in_fallback')
        render :authentication_fallback
      end
    end

    def destroy
      DfESignInUser.end_session!(session)

      redirect_to action: :new
    end

    def sign_in_by_email
      raise unless FeatureFlag.active?('dfe_sign_in_fallback')

      provider_user = ProviderUser.find_by(email_address: params.dig(:provider_user, :email_address).downcase.strip)

      if provider_user && provider_user.dfe_sign_in_uid.present?
        magic_link_token = MagicLinkToken.new
        ProviderMailer.fallback_sign_in_email(provider_user, magic_link_token.raw).deliver_later
        provider_user.update!(magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.zone.now)

        SlackNotificationWorker.perform_async(
          "Provider user #{provider_user.first_name} has requested a fallback sign in link",
          edit_support_interface_provider_user_url(provider_user),
        )
      end

      redirect_to provider_interface_check_your_email_path
    end

    def check_your_email; end

    def authenticate_with_token
      magic_link_token = MagicLinkToken.from_raw(params.fetch(:token))
      provider_user = ProviderUser.find_by!(magic_link_token: magic_link_token)

      SlackNotificationWorker.perform_async(
        "Provider user #{provider_user.first_name} has signed in via the fallback mechanism",
        edit_support_interface_provider_user_url(provider_user),
      )

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
