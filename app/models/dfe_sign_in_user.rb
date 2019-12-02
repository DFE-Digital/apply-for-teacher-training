class DfESignInUser
  attr_reader :email_address, :dfe_sign_in_uid

  def self.begin_session!(session, dfe_sign_in_session)
    session['dfe_user'] = {
      'email_address' => dfe_sign_in_session.email_address,
      'dfe_sign_in_uid' => dfe_sign_in_session.uid,
    }
  end

  def self.load_from_session(session)
    if session['dfe_user']
      new(
        email_address: session['dfe_user']['email_address'],
        dfe_sign_in_uid: session['dfe_user']['dfe_sign_in_uid'],
      )
    end
  end

  def self.end_session!(session)
    session.delete('dfe_user')
  end

  def initialize(email_address:, dfe_sign_in_uid:)
    @email_address = email_address
    @dfe_sign_in_uid = dfe_sign_in_uid
  end
end
