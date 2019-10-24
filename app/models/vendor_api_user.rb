class VendorApiUser < ApplicationRecord
  belongs_to :vendor_api_token

  validates :email, presence: true
  validates :user_id, presence: true
  validates :full_name, presence: true
end
