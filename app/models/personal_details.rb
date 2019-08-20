class PersonalDetails < ApplicationRecord
  MAX_LENGTHS = {
    first_name: 50,
    last_name: 50,
    preferred_name: 50,
    title: 4,
  }.freeze

  validates :first_name, :last_name, :title, presence: true

  MAX_LENGTHS.each { |field, max| validates field, length: { maximum: max } }
end
