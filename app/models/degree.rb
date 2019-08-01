class Degree < ApplicationRecord
  MAX_LENGTHS = {
    class_of_degree: 20,
    institution: 100,
    subject: 100,
    type_of_degree: 20
  }.freeze

  validates :type_of_degree, presence: true
  validates :subject, presence: true
  validates :institution, presence: true
  validates :class_of_degree, presence: true
  validates :year, presence: true

  validates :year, numericality: { greater_than: 1899, less_than_or_equal_to: DateTime.now.year }

  MAX_LENGTHS.each do |field, max|
    validates field, length: { maximum: max }
  end
end
