module SupportInterface
  module MagicLinkAuthentication
    def self.get_user_from_token!(token:)
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: 'SupportUser',
        raw_token: token,
      )

      authentication_token && authentication_token.still_valid? && authentication_token.user
    end
  end
end
