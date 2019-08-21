class Degree < ApplicationRecord
  MAX_LENGTHS = {
    type_of_degree: 20,
    subject: 100,
    institution: 100,
    class_of_degree: 20
  }.freeze

  validates :type_of_degree, :subject, :institution, :class_of_degree, :year, presence: true

  MAX_LENGTHS.each { |field, max| validates field, length: { maximum: max } }

  validates :year, numericality: { greater_than: 1899, less_than_or_equal_to: DateTime.now.year }
end
