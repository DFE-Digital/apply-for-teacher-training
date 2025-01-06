module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication, if: -> { one_login_enabled? }
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

private

  def authenticated?
    resume_session
  end

  def require_authentication
    current_candidate || resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    redirect_to candidate_interface_create_account_or_sign_in_path
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
