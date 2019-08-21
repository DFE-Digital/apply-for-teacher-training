class ContactDetails < ApplicationRecord
  MAX_LENGTHS = {
    phone_number: 35,
    email_address: 250,
    address: 250
  }.freeze

  validates :phone_number, :email_address, :address, presence: true

  MAX_LENGTHS.each { |field, max| validates field, length: { maximum: max } }
end
