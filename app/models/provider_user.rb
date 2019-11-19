class ProviderUser
  attr_reader :email_address

  def self.begin_session!(session, dfe_sign_in_session)
    session['provider_user'] = {
      'email_address' => dfe_sign_in_session.email_address,
      'dfe_sign_in_uid' => dfe_sign_in_session.uid,
    }
  end

  def self.load_from_session(session)
    if session['provider_user']
      new(
        email_address: session['provider_user']['email_address'],
        dfe_sign_in_uid: session['provider_user']['dfe_sign_in_uid'],
      )
    end
  end

  def initialize(email_address:, dfe_sign_in_uid:)
    @email_address = email_address
    @dfe_sign_in_uid = dfe_sign_in_uid
  end

  def provider
    Provider.find_by(code: 'ABC')
  end
end
