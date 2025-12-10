module DfESigninAuth
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

private

  def authenticated?
    resume_session
  end

  def require_authentication
    authenticated? || request_authentication
  end

  def resume_session
    session = Current.dfe_session ||= find_session_by_cookie

    if session.present?
      session.touch
      session
    else
      terminate_session
      nil
    end
  end

  def candidate_interface?
    support_interface_path == session['post_dfe_sign_in_path'] ||
      interface == 'SupportInterface'
  end

  def provider_interface?
    provider_interface_path == session['post_dfe_sign_in_path'] ||
      interface == 'ProviderInterface'
  end

  def interface
    @interface ||= self.class.name.split(':').first
  end

  def find_session_by_cookie
    user_type = if candidate_interface?
                  'SupportUser'
                elsif provider_interface?
                  'ProviderUser'
                end

    DfESigninSession.find_by(
      'id = ? AND updated_at > ? AND user_type = ?',
      cookies.signed[:dsi_session_id],
      2.hours.ago,
      user_type,
    )
  end

  def request_authentication
    if candidate_interface?
      redirect_to support_interface_sign_in_path
    else
      redirect_to provider_interface_sign_in_path
    end
  end

  def start_new_dsi_session(user:, omniauth_payload:)
    ActiveRecord::Base.transaction do
      unless authenticated?
        user.dfe_signin_sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          email_address: omniauth_payload.dig('info', 'email'),
          dfe_sign_in_uid: omniauth_payload['uid'],
          first_name: omniauth_payload.dig('info', 'first_name'),
          last_name: omniauth_payload.dig('info', 'last_name'),
          last_active_at: Time.zone.now,
          id_token: omniauth_payload.dig('credentials', 'id_token'),
        ).tap do |dfe_session|
          Current.dfe_session = dfe_session
          cookies.signed.permanent[:dsi_session_id] = {
            value: dfe_session.id,
            httponly: true,
            same_site: :lax,
            secure: HostingEnvironment.production? || HostingEnvironment.sandbox_mode? || HostingEnvironment.qa?,
          }
        end

        user.update!(last_signed_in_at: Time.zone.now)
      end
    end
  end

  def terminate_session
    Current.dfe_session&.delete
    Current.dfe_session = nil
    cookies.delete(:dsi_session_id)
    reset_session
  end
end
