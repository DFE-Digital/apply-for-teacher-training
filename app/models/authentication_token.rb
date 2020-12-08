class AuthenticationToken < ApplicationRecord
  MAX_TOKEN_DURATION = 1.hour

  belongs_to :authenticable, polymorphic: true

  def still_valid?
    created_at > (Time.zone.now - MAX_TOKEN_DURATION)
  end

  def self.find_by_hashed_token(authenticable_type:, raw_token:)
    hashed_token = MagicLinkToken.from_raw(raw_token)

    AuthenticationToken.where(
      authenticable_type: authenticable_type,
    ).find_by(
      hashed_token: hashed_token,
    )
  end
end
