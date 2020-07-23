module ProviderInterface
  module MagicLinkAuthentication
    def self.send_token!(provider_user:)
      magic_link_token = MagicLinkToken.new
      provider_user.authentication_tokens.create!(hashed_token: magic_link_token.encrypted)
      ProviderMailer.fallback_sign_in_email(provider_user, magic_link_token.raw).deliver_later
    end
  end
end
