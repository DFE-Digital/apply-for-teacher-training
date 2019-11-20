module DfESignIn
  DfESignInSession = Struct.new(:email_address, :uid)

  def self.parse_auth_hash(openid_auth_hash)
    DfESignInSession.new(
      openid_auth_hash['info']['email'],
      openid_auth_hash['uid'],
    )
  end

  def self.bypass?
    Rails.env.development? && ENV['BYPASS_DFE_SIGN_IN'] == 'true'
  end
end
