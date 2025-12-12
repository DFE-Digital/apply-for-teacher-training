module ProviderUserAuth
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
    impersonate_provider_user_id = cookies.signed[:impersonate_provider_user_id]

    ## This works fine to impersonate
    # but you need to clear the impersonate cookie once you're done.
    # login in as provider after impersonation doesn't work
    # because the cookie is still there
    session = if impersonate_provider_user_id.present?
                find_support_session(impersonate_provider_user_id)
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

  def find_support_session(impersonate_provider_user_id)
    Current.support_session ||= DfESigninSession.find_by(
      'id = ? AND updated_at > ? AND user_type = ? AND impersonated_provider_user_id = ?',
      cookies.signed[:support_session_id],
      2.hours.ago,
      'SupportUser',
      impersonate_provider_user_id,
    )
  end

  def find_provider_session
    Current.provider_session ||= DfESigninSession.find_by(
      'id = ? AND updated_at > ? AND user_type = ?',
      cookies.signed[:provider_session_id],
      2.hours.ago,
      'ProviderUser',
    )
  end

  def request_authentication
    redirect_to provider_interface_sign_in_path
  end

  def terminate_session
    Current.provider_session&.delete
    Current.provider_session = nil
    cookies.delete(:provider_session_id)
    # reset_session
  end
end
