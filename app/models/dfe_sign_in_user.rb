class DfESignInUser
  attr_reader :email_address, :dfe_sign_in_uid, :impersonated_provider_user, :id_token
  attr_accessor :first_name, :last_name

  # we need to be able to redirect back to our sign-out callback path
  include Rails.application.routes.url_helpers

  def initialize(email_address:, dfe_sign_in_uid:, first_name:, last_name:, id_token: nil, impersonated_provider_user: nil)
    @email_address = email_address&.downcase
    @dfe_sign_in_uid = dfe_sign_in_uid
    @first_name = first_name
    @last_name = last_name
    @id_token = id_token
    @impersonated_provider_user = impersonated_provider_user
  end

  def provider_interface_dsi_logout_url
    if FeatureFlag.active?(:separate_dsi_controllers)
      query = {
        post_logout_redirect_uri: auth_dfe_sign_out_url,
        id_token_hint: @id_token,
      }

      "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
    else
      dsi_logout_url(interface: :provider)
    end
  end

  def support_interface_dsi_logout_url
    if FeatureFlag.active?(:separate_dsi_controllers)
      query = {
        post_logout_redirect_uri: auth_dfe_support_sign_out_url,
        id_token_hint: @id_token,
      }

      "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
    else
      dsi_logout_url(interface: :support)
    end
  end

  def needs_dsi_signout?
    @id_token.present?
  end

  def self.begin_session!(session, omniauth_payload)
    session['dfe_sign_in_user'] = {
      'email_address' => omniauth_payload.dig('info', 'email'),
      'dfe_sign_in_uid' => omniauth_payload['uid'],
      'first_name' => omniauth_payload.dig('info', 'first_name'),
      'last_name' => omniauth_payload.dig('info', 'last_name'),
      'last_active_at' => Time.zone.now,
      'id_token' => omniauth_payload.dig('credentials', 'id_token'),
    }
  end

  def self.load_from_session(session)
    dfe_sign_in_session = session['dfe_sign_in_user']
    return unless dfe_sign_in_session

    # Users who signed in before session expiry was implemented will not have
    # `last_active_at` set. In that case, force them to sign in again.
    return unless dfe_sign_in_session['last_active_at']

    return if dfe_sign_in_session.fetch('last_active_at') < 2.hours.ago

    dfe_sign_in_session['last_active_at'] = Time.zone.now

    new(
      email_address: dfe_sign_in_session['email_address'],
      dfe_sign_in_uid: dfe_sign_in_session['dfe_sign_in_uid'],
      first_name: dfe_sign_in_session['first_name'],
      last_name: dfe_sign_in_session['last_name'],
      id_token: dfe_sign_in_session['id_token'],
      impersonated_provider_user: impersonated_provider_user_from(session),
    )
  end

  def begin_impersonation!(session, provider_user)
    session['impersonated_provider_user'] = { 'provider_user_id' => provider_user.id }
  end

  def end_impersonation!(session)
    session.delete('impersonated_provider_user')
  end

  def self.end_session!(session)
    session.delete('post_dfe_sign_in_path')
    session.delete('dfe_sign_in_user')
    session.delete('impersonated_provider_user')
  end

  def self.impersonated_provider_user_from(session)
    if session['impersonated_provider_user']
      ProviderUser.find session['impersonated_provider_user']['provider_user_id']
    end
  end

private

  # a URL the user can visit to log them out of DSI and be redirected to our
  # after-sign-out path where we'll delete their local session
  def dsi_logout_url(interface:)
    query = {
      post_logout_redirect_uri: auth_dfe_sign_out_url,
      id_token_hint: @id_token,
      state: interface,
    }
    "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
  end
end
