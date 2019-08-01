class ContactDetails < ApplicationRecord
  MAX_LENGTHS = {
    address: 250,
    email_address: 250,
    phone_number: 35
  }.freeze

  validates :address, :email_address, :phone_number, presence: true

  MAX_LENGTHS.each do |field, max|
    validates field, length: { maximum: max }
  end
end
