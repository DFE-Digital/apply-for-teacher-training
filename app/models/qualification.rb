class Qualification < ApplicationRecord
  MAX_LENGTHS = {
    grade: 20,
    institution: 100,
    subject: 100,
    type_of_qualification: 20
  }.freeze

  validates :type_of_qualification, :subject, :institution, :grade, :year, presence: true

  MAX_LENGTHS.each { |field, max| validates field, length: { maximum: max } }

  validates :year, numericality: { greater_than: 1899, less_than_or_equal_to: DateTime.now.year }
end
