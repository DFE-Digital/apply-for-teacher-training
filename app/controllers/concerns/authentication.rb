module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication, if: -> { one_login_enabled? }
    helper_method :authenticated?
  end

private

  def authenticated?
    current_candidate || resume_session
  end

  def require_authentication
    authenticated? || request_authentication
  end

  def resume_session
    if !one_login_enabled?
      terminate_session
      return nil
    end

    session = Current.session ||= find_session_by_cookie

    if session.present?
      session.touch
      session
    else
      terminate_session
      nil
    end
  end

  def find_session_by_cookie
    Session.find_by(
      'id = ? AND updated_at > ?', cookies.signed[:session_id], 7.days.ago
    )
  end

  def request_authentication
    redirect_to candidate_interface_create_account_or_sign_in_path(path: request.url)
  end

  def start_new_session_for(candidate:, id_token_hint: nil)
    ActiveRecord::Base.transaction do
      unless authenticated?
        candidate.sessions.create!(
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          id_token_hint:,
        ).tap do |session|
          Current.session = session
          cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
        end

        candidate.update!(last_signed_in_at: Time.zone.now)
      end
    end
  end

  def terminate_session
    Current.session&.destroy
    Current.session = nil
    cookies.delete(:session_id)
    reset_session
  end

  def one_login_enabled?
    FeatureFlag.active?(:one_login_candidate_sign_in)
  end
end
