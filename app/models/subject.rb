class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  validates :code, uniqueness: true

  SKE_STANDARD_COURSES = %w[
    C1
    F1
    11
    DT
    Q3
    16
    G1
    F0
    F3
    V6
  ].freeze

  SKE_LANGUAGE_COURSES = %w[
    15
    17
    18
    19
    20
    21
    22
    24
  ].freeze
end
