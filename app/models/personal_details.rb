class PersonalDetails < ApplicationRecord
  DATE_OF_BIRTH_LIMIT = 1900
  MAX_LENGTHS = {
    first_name: 50,
    last_name: 50,
    preferred_name: 50,
    title: 4,
  }.freeze

  validates :first_name, :last_name, :title, :date_of_birth, presence: true

  validate :date_of_birth, :date_is_not_too_old

  MAX_LENGTHS.each do |field, max|
    validates field, length: { maximum: max }
  end

private

  def date_is_not_too_old
    if date_of_birth.present? && date_of_birth.year < DATE_OF_BIRTH_LIMIT
      errors.add(:date_of_birth, :too_old, year: DATE_OF_BIRTH_LIMIT)
    end
  end
end
