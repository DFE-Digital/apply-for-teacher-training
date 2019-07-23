class ContactDetails < ApplicationRecord
  validates :phone_number, :email_address, :address, presence: true
end
