module SupportInterface
  module MagicLinkAuthentication
    TOKEN_DURATION = 1.hour

    def self.send_token!(support_user:)
      magic_link_token = support_user.create_magic_link_token!
      SupportMailer.fallback_sign_in_email(support_user, magic_link_token).deliver_later
    end

    def self.get_user_from_token!(token:)
      hashed_token = MagicLinkToken.from_raw(token)
      AuthenticationToken.where('created_at > ?', TOKEN_DURATION.ago)
        .find_by!(hashed_token: hashed_token)
        .user
    end
  end
end
