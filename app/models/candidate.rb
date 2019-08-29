class Candidate < ApplicationRecord
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  devise

  validates :email_address, presence: true, uniqueness: true, length: { maximum: 250 }
end
