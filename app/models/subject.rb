class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  validates :code, uniqueness: true

  SKE_STANDARD_COURSES = %w[
    F1
    11
    16
    G1
    F0
    F3
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

  SKE_PHYSICS_COURSES = %w[
    F0
    F3
  ].freeze
end
