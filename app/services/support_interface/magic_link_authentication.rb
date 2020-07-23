module SupportInterface
  module MagicLinkAuthentication
    TOKEN_DURATION = 1.hour

    def self.send_token!(support_user:)
      magic_link_token = MagicLinkToken.new
      support_user.authentication_tokens.create!(hashed_token: magic_link_token.encrypted)
      SupportMailer.fallback_sign_in_email(support_user, magic_link_token.raw).deliver_later
    end
  end
end
