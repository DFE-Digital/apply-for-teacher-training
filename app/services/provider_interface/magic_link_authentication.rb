module ProviderInterface
  module MagicLinkAuthentication
    TOKEN_DURATION = 1.hour

    def self.send_token!(provider_user:)
      magic_link_token = MagicLinkToken.new
      provider_user.update!(magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.zone.now)
      ProviderMailer.fallback_sign_in_email(provider_user, magic_link_token.raw).deliver_later
    end

    def self.get_user_from_token!(token:)
      magic_link_token = MagicLinkToken.from_raw(token)
      ProviderUser.where('magic_link_token_sent_at > ?', TOKEN_DURATION.ago)
        .find_by!(magic_link_token: magic_link_token)
    end
  end
end
