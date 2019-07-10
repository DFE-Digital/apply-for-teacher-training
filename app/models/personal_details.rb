class PersonalDetails < ApplicationRecord
  validates :title, presence: :true
end
