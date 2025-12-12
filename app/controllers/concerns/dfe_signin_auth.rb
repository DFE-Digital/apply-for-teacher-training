module DfESigninAuth
  extend ActiveSupport::Concern

  # Figure out the mask icon in the navigation bar
  # for support

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
    session = Current.support_session ||= find_session_by_cookie

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
      'id = ? AND updated_at > ? AND user_type = ?',
      cookies.signed[:support_session_id],
      2.hours.ago,
      'SupportUser',
    )
  end

  def request_authentication
    redirect_to support_interface_sign_in_path
  end

  def terminate_session
    Current.support_session&.delete
    Current.support_session = nil
    cookies.delete(:support_session_id)
    cookies.delete(:impersonate_provider_user_id)
    # reset_session
  end
end
