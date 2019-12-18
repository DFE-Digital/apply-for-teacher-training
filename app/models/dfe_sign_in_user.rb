class DfESignInUser
  attr_reader :email_address, :dfe_sign_in_uid

  def initialize(email_address:, dfe_sign_in_uid:)
    @email_address = email_address
    @dfe_sign_in_uid = dfe_sign_in_uid
  end

  def self.begin_session!(session, omniauth_payload)
    session['dfe_sign_in_user'] = {
      'email_address' => omniauth_payload['info']['email'],
      'dfe_sign_in_uid' => omniauth_payload['uid'],
    }
  end

  def self.load_from_session(session)
    dfe_sign_in_session = session['dfe_sign_in_user']
    return unless dfe_sign_in_session

    new(
      email_address: dfe_sign_in_session['email_address'],
      dfe_sign_in_uid: dfe_sign_in_session['dfe_sign_in_uid'],
    )
  end

  def self.end_session!(session)
    session.delete('dfe_sign_in_user')
  end
end
