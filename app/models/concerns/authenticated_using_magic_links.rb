module AuthenticatedUsingMagicLinks
  extend ActiveSupport::Concern

  included do
    has_many :authentication_tokens, as: :user, dependent: :destroy
  end

  def create_magic_link_token!(path: nil)
    magic_link_token = MagicLinkToken.new
    AuthenticationToken.create!(user: self, hashed_token: magic_link_token.encrypted, path: path)
    magic_link_token.raw
  end

  class_methods do
    def authenticate!(token)
      authentication_token = AuthenticationToken.find_by_hashed_token(
        user_type: name,
        raw_token: token,
      )

      authentication_token&.still_valid? &&
        authentication_token&.use! &&
        authentication_token&.user
    end
  end
end
