class VendorApiToken < ApplicationRecord
  belongs_to :provider

  def self.create_with_random_token!(provider:)
    unhashed_token, hashed_token = Devise.token_generator.generate(VendorApiToken, :hashed_token)
    create!(hashed_token: hashed_token, provider: provider)
    unhashed_token
  end

  def self.find_by_unhashed_token(unhashed_token)
    hashed_token = Devise.token_generator.digest(VendorApiToken, :hashed_token, unhashed_token)
    find_by(hashed_token: hashed_token)
  end
end
