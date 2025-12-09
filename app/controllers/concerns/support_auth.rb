module SupportAuth
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

private

  def authenticated?
    @current_support_user || resume_session
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

  def find_session_by_cookie
    DfESigninSession.find_by(
      'id = ? AND updated_at > ?', cookies.signed[:dfe_session_id], 2.hours.ago
    )
  end

  def request_authentication
    redirect_to support_interface_sign_in_path
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
          cookies.signed.permanent[:dfe_session_id] = {
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
    Current.dfe_session&.destroy
    Current.dfe_session = nil
    cookies.delete(:dfe_session_id)
    reset_session
  end
end
