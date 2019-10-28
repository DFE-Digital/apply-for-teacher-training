class VendorApiUser < ApplicationRecord
  belongs_to :vendor_api_token

  validates :email_address, presence: true
  validates :vendor_user_id, presence: true
  validates :full_name, presence: true
end
