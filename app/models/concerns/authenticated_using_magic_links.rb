module AuthenticatedUsingMagicLinks
  extend ActiveSupport::Concern

  included do
    has_many :authentication_tokens, as: :user, dependent: :destroy
  end

  def magic_link_recently_requested?
    return false if is_a?(ServiceAPIUser)

    last_magic_link_request = AuthenticationToken.where(user: self).order(:created_at).last
    return false if last_magic_link_request.blank?

    last_magic_link_request.created_at > 1.minute.ago
  end

  def create_magic_link_token!(path: nil)
    raise MagicLinkTokenAlreadyRequestedError if magic_link_recently_requested?

    magic_link_token = MagicLinkToken.new
    AuthenticationToken.create!(user: self, hashed_token: magic_link_token.encrypted, path:)
    magic_link_token.raw
  end

  class_methods do
    def authenticate!(token)
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: name,
        raw_token: token,
      )

      authentication_token&.still_valid? &&
        authentication_token.use! &&
        authentication_token.user
    end
  end

  class MagicLinkTokenAlreadyRequestedError < StandardError; end
end
