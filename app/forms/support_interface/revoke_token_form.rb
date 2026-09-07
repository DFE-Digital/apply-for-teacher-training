module SupportInterface
  class RevokeTokenForm
    include ActiveModel::Model

    attr_accessor :api_token, :audit_comment
    validates :audit_comment, presence: true
    validates_with ZendeskUrlValidator

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        api_token.update(
          hashed_token: SecureRandom.hex + Time.zone.now.to_i.to_s,
          audit_comment:,
        )
        api_token.discard!
      end
    end
  end
end
