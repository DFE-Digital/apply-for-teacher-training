module SupportInterface
  class SessionsController < SupportInterfaceController
    skip_before_action :authenticate_support_user!, except: :destroy
    skip_before_action :require_authentication, except: :destroy

    def new
      redirect_to support_interface_path and return if current_support_user

      session['post_dfe_sign_in_path'] ||= support_interface_path
      if FeatureFlag.active?('dfe_sign_in_fallback')
        @support_user = SupportUser.new
        render :authentication_fallback
      end
    end

    def destroy
      post_signout_redirect = if dfe_sign_in_user.needs_dsi_signout?
                                dfe_sign_in_user.support_interface_dsi_logout_url
                              else
                                support_interface_path
                              end

      DfESignInUser.end_session!(session)
      redirect_to post_signout_redirect, allow_other_host: true
    end

    def sign_in_by_email
      render_404 and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      email_address = params.dig(:support_user, :email_address).downcase.strip

      if email_address.blank?
        invalid_email_address!(email_address, :blank) and return
      elsif email_address !~ URI::MailTo::EMAIL_REGEXP
        invalid_email_address!(email_address, :invalid) and return
      end

      support_user = SupportUser.find_by(email_address:)

      send_new_authentication_token! support_user
    end

    def confirm_authentication_with_token
      if FeatureFlag.active?('dfe_sign_in_fallback')
        authentication_token = look_up_token params.fetch(:token)

        if authentication_token
          render :expired_token unless authentication_token.still_valid?
        else
          render_404
        end
      else
        redirect_to support_interface_sign_in_path
      end
    end

    def request_new_token
      authentication_token = look_up_token params.fetch(:token)

      send_new_authentication_token! authentication_token.user
    end

    def authenticate_with_token
      redirect_to action: :new and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      support_user = SupportUser.authenticate!(params.fetch(:token))

      render_404 and return unless support_user

      # Equivalent to calling DfESignInUser.begin_session!
      session['dfe_sign_in_user'] = {
        'email_address' => support_user.email_address,
        'dfe_sign_in_uid' => support_user.dfe_sign_in_uid,
        'first_name' => support_user.first_name,
        'last_name' => support_user.last_name,
        'last_active_at' => Time.zone.now,
      }

      support_user.update!(last_signed_in_at: Time.zone.now)

      redirect_to support_interface_candidates_path
    end

    def confirm_environment
      @confirmation = SupportInterface::ConfirmEnvironment.new(from: params[:from])
    end

    def confirmed_environment
      @confirmation = SupportInterface::ConfirmEnvironment.new(params.expect(support_interface_confirm_environment: %i[from environment]))

      if @confirmation.valid?
        session[:confirmed_environment_at] = Time.zone.now
        redirect_to @confirmation.from
      else
        render :confirm_environment
      end
    end

  private

    def look_up_token(token)
      AuthenticationToken.find_by_hashed_token(
        user_type: 'SupportUser',
        raw_token: token,
      )
    end

    def send_new_authentication_token!(user)
      if user && user.dfe_sign_in_uid.present?
        magic_link_token = user.create_magic_link_token!
        SupportMailer.fallback_sign_in_email(user, magic_link_token).deliver_later
      end

      redirect_to support_interface_check_your_email_path
    end

    def invalid_email_address!(email_address, error_type)
      @support_user = SupportUser.new
      @support_user.email_address = email_address
      @support_user.errors.add(:email_address, error_type)
      render :authentication_fallback
    end
  end
end
