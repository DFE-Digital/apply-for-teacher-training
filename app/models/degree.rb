class Degree < ApplicationRecord
  validates :type_of_degree, presence: true
  validates :subject, presence: true
  validates :institution, presence: true
  validates :class_of_degree, presence: true
  validates :year, presence: true
end
