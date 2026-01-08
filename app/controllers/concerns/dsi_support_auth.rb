module DsiSupportAuth
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  def find_session_by_cookie
    # there's a similar method to this in rack_app.rb
    DsiSession.find_by(
      'id = ? AND updated_at > ? AND user_type = ?',
      cookies.signed[:support_session_id],
      2.hours.ago,
      'SupportUser',
    )
  end

private

  def authenticated?
    resume_session
  end

  def require_authentication
    authenticated? || request_authentication
  end

  def resume_session
    session = Current.support_session ||= find_session_by_cookie

    if session.present?
      session.touch
      session
    else
      terminate_session
      nil
    end
  end

  def start_new_dsi_session(user:, omniauth_payload:)
    ActiveRecord::Base.transaction do
      unless authenticated?
        user.dsi_sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          email_address: omniauth_payload.dig('info', 'email'),
          dfe_sign_in_uid: omniauth_payload['uid'],
          first_name: omniauth_payload.dig('info', 'first_name'),
          last_name: omniauth_payload.dig('info', 'last_name'),
          last_active_at: Time.zone.now,
          id_token: omniauth_payload.dig('credentials', 'id_token'),
        ).tap do |session|
          Current.support_session = session
          cookies.signed.permanent[:support_session_id] = {
            value: session.id,
            httponly: true,
            same_site: :lax,
            secure: !Rails.env.test? && (HostingEnvironment.production? || HostingEnvironment.sandbox_mode? || HostingEnvironment.qa?),
          }
        end

        user.update!(last_signed_in_at: Time.zone.now)
      end
    end
  end

  def request_authentication
    session['post_dfe_sign_in_path'] = request.fullpath
    redirect_to support_interface_sign_in_path
  end

  def terminate_session
    Current.support_session&.delete
    Current.support_session = nil
    cookies.delete(:support_session_id)
    cookies.delete(:impersonated_provider_user_id)
  end
end
