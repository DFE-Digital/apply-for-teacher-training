class TokenSignin
  def self.get_user_from_token!(token:)
    hashed_token = MagicLinkToken.from_raw(token)
    AuthenticationToken.where('created_at > ?', TOKEN_DURATION.ago)
      .find_by!(hashed_token: hashed_token)
      .authenticable
  end
end
