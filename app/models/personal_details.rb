class PersonalDetails < ApplicationRecord
  MAX_LENGTHS = {
    title: 4,
    first_name: 50,
    preferred_name: 50,
    last_name: 50
  }.freeze

  validates :title, :first_name, :last_name, presence: true

  MAX_LENGTHS.each { |field, max| validates field, length: { maximum: max } }
end
