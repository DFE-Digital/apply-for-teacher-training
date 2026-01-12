module DsiProviderAuth
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication, if: -> { FeatureFlag.active?(:dsi_stateful_session) }
    helper_method :authenticated?
  end

  def find_provider_session
    Current.provider_session ||= DsiSession.find_by(
      'id = ? AND updated_at > ? AND user_type = ?',
      cookies.signed[:provider_session_id],
      2.hours.ago,
      'ProviderUser',
    )
  end

  def authenticated?
    resume_session
  end

private

  def require_authentication
    authenticated? || request_authentication
  end

  def resume_session
    impersonated_provider_user_id = cookies.signed[:impersonated_provider_user_id]

    session = if impersonated_provider_user_id.present?
                find_support_session(impersonated_provider_user_id)
              else
                find_provider_session
              end

    if session.present?
      session.touch
      session
    else
      terminate_session
      nil
    end
  end

  def find_support_session(impersonated_provider_user_id)
    Current.support_session ||= DsiSession.find_by(
      'id = ? AND updated_at > ? AND user_type = ? AND impersonated_provider_user_id = ?',
      cookies.signed[:support_session_id],
      2.hours.ago,
      'SupportUser',
      impersonated_provider_user_id,
    )
  end

  def request_authentication
    session['post_dfe_sign_in_path'] = request.fullpath
    redirect_to provider_interface_sign_in_path
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
          Current.provider_session = session
          cookies.signed.permanent[:provider_session_id] = {
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

  def terminate_session
    Current.provider_session&.delete
    Current.provider_session = nil
    cookies.delete(:provider_session_id)
  end
end
