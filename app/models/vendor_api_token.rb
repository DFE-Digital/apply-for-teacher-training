class VendorAPIToken < ApplicationRecord
  belongs_to :provider

  audited associated_with: :provider

  scope :used_in_last_3_months, -> { where('last_used_at >= ?', 3.months.ago) }

  def self.create_with_random_token!(attributes = {}, provider:)
    unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
    create!(attributes.merge({ hashed_token:, provider: }))
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(VendorAPIToken, :hashed_token, unhashed_token)
    find_by(hashed_token:)
  end
end
