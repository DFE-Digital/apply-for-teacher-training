class MagicLinkSignIn
  def self.call(candidate:)
    magic_link_token = MagicLinkToken.new
    AuthenticationMailer.sign_in_email(candidate: candidate, token: magic_link_token.raw).deliver_later
    candidate.update!(magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.now)
  end
end
