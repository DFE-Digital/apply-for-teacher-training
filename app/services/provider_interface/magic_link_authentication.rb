module ProviderInterface
  module MagicLinkAuthentication
    def self.send_token!(provider_user:)
      magic_link_token = provider_user.create_magic_link_token!
      ProviderMailer.fallback_sign_in_email(provider_user, magic_link_token).deliver_later
    end

    def self.get_user_from_token!(token:)
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'ProviderUser',
        raw_token: token,
      )

      authentication_token && authentication_token.still_valid? && authentication_token.user
    end
  end
end
