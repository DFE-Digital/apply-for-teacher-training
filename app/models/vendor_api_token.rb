class VendorAPIToken < ApplicationRecord
  belongs_to :provider

  audited associated_with: :provider

  def self.create_with_random_token!(provider:)
    unhashed_token, hashed_token = Devise.token_generator.generate(VendorAPIToken, :hashed_token)
    create!(hashed_token: hashed_token, provider: provider)
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(VendorAPIToken, :hashed_token, unhashed_token)
    find_by(hashed_token: hashed_token)
  end
end
