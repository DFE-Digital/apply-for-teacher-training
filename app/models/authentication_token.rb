class AuthenticationToken < ApplicationRecord
  MAX_TOKEN_DURATION = 1.hour

  belongs_to :user, polymorphic: true

  def still_valid?
    created_at.present? && created_at > (Time.zone.now - MAX_TOKEN_DURATION) && used_at.nil?
  end

  def self.find_by_hashed_token(user_type:, raw_token:)
    hashed_token = MagicLinkToken.from_raw(raw_token)

    AuthenticationToken.where(
      user_type:,
    ).find_by(
      hashed_token:,
    )
  end

  def use!
    transaction do
      user.update!(last_signed_in_at: Time.zone.now)
      update!(used_at: Time.zone.now)
    end
  end
end
