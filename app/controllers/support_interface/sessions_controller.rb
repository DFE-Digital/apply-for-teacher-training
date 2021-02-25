module SupportInterface
  class SessionsController < SupportInterfaceController
    skip_before_action :authenticate_support_user!, except: :destroy

    def new
      redirect_to support_interface_path and return if current_support_user

      session['post_dfe_sign_in_path'] ||= support_interface_path
      if FeatureFlag.active?('dfe_sign_in_fallback')
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
      redirect_to post_signout_redirect
    end

    def sign_in_by_email
      render_404 and return unless FeatureFlag.active?('dfe_sign_in_fallback')

      support_user = SupportUser.find_by(email_address: params.dig(:support_user, :email_address).downcase.strip)

      if support_user
        magic_link_token = support_user.create_magic_link_token!
        SupportMailer.fallback_sign_in_email(support_user, magic_link_token).deliver_later
      end

      redirect_to support_interface_check_your_email_path
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
      @confirmation = SupportInterface::ConfirmEnvironment.new(params.require(:support_interface_confirm_environment).permit(:from, :environment))

      if @confirmation.valid?
        session[:confirmed_environment_at] = Time.zone.now
        redirect_to @confirmation.from
      else
        render :confirm_environment
      end
    end
  end
end
