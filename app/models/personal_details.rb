class PersonalDetails < ApplicationRecord
  validates :title, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :nationality, presence: true
end
