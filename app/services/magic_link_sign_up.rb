require_relative 'lib/magic_link_token'

class MagicLinkSignUp
  def self.call(candidate:)
    magic_link_token = MagicLinkToken.new
    AuthenticationMailer.sign_up_email(to: candidate.email_address, token: magic_link_token.raw).deliver!
    candidate.update!(magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.now)
  end
end
