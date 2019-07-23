class PersonalDetails < ApplicationRecord
  # Personal Details
  validates :title, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  # Contact Details
  validates :phone_number, :email_address, :address, presence: true, on: :update
end
