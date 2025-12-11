module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!, except: :destroy
    skip_before_action :require_authentication, except: :destroy
    skip_before_action :redirect_if_setup_required

    def new
      redirect_to provider_interface_applications_path and return if impersonation?

      if FeatureFlag.active?('dfe_sign_in_fallback')
        @provider_user = ProviderUser.new

        render :authentication_fallback
      end
    end

    def destroy
      post_signout_redirect = if DfESignIn.bypass?
                                provider_interface_path
                              else
                                dsi_logout_url(interface: :provider)
                              end

      terminate_session
      redirect_to post_signout_redirect, allow_other_host: true
    end

    def sign_in_by_email
      render_404 and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      email_address = params.dig(:provider_user, :email_address).downcase.strip

      if email_address.blank?
        invalid_email_address!(email_address, :blank) and return
      elsif email_address !~ URI::MailTo::EMAIL_REGEXP
        invalid_email_address!(email_address, :invalid) and return
      end

      provider_user = ProviderUser.find_by(email_address:)

      send_new_authentication_token! provider_user
    end

    def check_your_email; end

    def confirm_authentication_with_token
      if FeatureFlag.active?('dfe_sign_in_fallback')
        authentication_token = look_up_token params.fetch(:token)

        if authentication_token
          render :expired_token unless authentication_token.still_valid?
        else
          render_404
        end
      else
        redirect_to provider_interface_sign_in_path
      end
    end

    def request_new_token
      authentication_token = look_up_token params.fetch(:token)

      send_new_authentication_token! authentication_token.user
    end

    def authenticate_with_token
      redirect_to action: :new and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      provider_user = ProviderUser.authenticate!(params.fetch(:token))

      render_404 and return unless provider_user

      # Equivalent to calling DfESignInUser.begin_session!
      session['dfe_sign_in_user'] = {
        'email_address' => provider_user.email_address,
        'dfe_sign_in_uid' => provider_user.dfe_sign_in_uid,
        'first_name' => provider_user.first_name,
        'last_name' => provider_user.last_name,
        'last_active_at' => Time.zone.now,
      }

      provider_user.update!(last_signed_in_at: Time.zone.now)

      redirect_to session['post_dfe_sign_in_path'] || provider_interface_applications_path
    end

  private

    def look_up_token(token)
      AuthenticationToken.find_by_hashed_token(
        user_type: 'ProviderUser',
        raw_token: token,
      )
    end

    def send_new_authentication_token!(user)
      if user && user.dfe_sign_in_uid.present?
        magic_link_token = user.create_magic_link_token!
        ProviderMailer.fallback_sign_in_email(user, magic_link_token).deliver_later
      end

      redirect_to provider_interface_check_your_email_path
    end

    def impersonation?
      ProviderImpersonation.load_from_session(session)
    end

    def invalid_email_address!(email_address, error_type)
      @provider_user = ProviderUser.new
      @provider_user.email_address = email_address
      @provider_user.errors.add(:email_address, error_type)
      render :authentication_fallback
    end
  end
end
