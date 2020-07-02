class DfESignInUser
  attr_reader :email_address, :dfe_sign_in_uid
  attr_accessor :first_name, :last_name

  # we need to be able to redirect back to our sign-out callback path
  include Rails.application.routes.url_helpers

  def initialize(email_address:, dfe_sign_in_uid:, first_name:, last_name:, id_token: nil)
    @email_address = email_address&.downcase
    @dfe_sign_in_uid = dfe_sign_in_uid
    @first_name = first_name
    @last_name = last_name
    @id_token = id_token
  end

  def provider_interface_logout_url
    logout_url_for(interface: :provider)
  end

  def support_interface_logout_url
    logout_url_for(interface: :support)
  end

  def self.begin_session!(session, omniauth_payload)
    session['dfe_sign_in_user'] = {
      'email_address' => omniauth_payload['info']['email'],
      'dfe_sign_in_uid' => omniauth_payload['uid'],
      'first_name' => omniauth_payload['info']['first_name'],
      'last_name' => omniauth_payload['info']['last_name'],
      'last_active_at' => Time.zone.now,
      'id_token' => omniauth_payload['credentials']['id_token'],
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
    )
  end

  def self.end_session!(session)
    session.delete('post_dfe_sign_in_path')
    session.delete('dfe_sign_in_user')
  end

private

  # a URL the user can visit to log them out of DSI and be redirected to our
  # after-sign-out path where we'll delete their local session
  def logout_url_for(interface:)
    dsi_logout_url = URI.parse("#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end").tap do |url|
      url.query = {
        post_logout_redirect_uri: auth_dfe_sign_out_url,
        id_token_hint: @id_token,
        state: interface,
      }.to_query
    end

    dsi_logout_url.to_s
  end
end
