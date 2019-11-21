class MagicLinkSignUp
  def self.call(candidate:)
    magic_link_token = MagicLinkToken.new
    AuthenticationMailer.sign_up_email(to: candidate.email_address, token: magic_link_token.raw).deliver_now
    candidate.update!(magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.now)
    StateChangeNotifier.call(:magic_link_sign_up, candidate: candidate)
  end
end
