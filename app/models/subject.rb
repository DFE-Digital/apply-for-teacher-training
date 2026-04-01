class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  validates :code, uniqueness: true

  scope :languages, -> { where(code: LANGUAGE_CODES) }
  scope :physics, -> { where(code: PHYSICS_CODES) }

  PHYSICS_CODES = [
    'F3', # Physics
  ].freeze

  LANGUAGE_CODES = [
    '17', # German
    '24', # Modern languages (other)
    '22', #	Spanish
    '21', #	Russian
    '20', #	Mandarin
    'A0', #	Latin
    '19',	# Japanese
    '18', #	Italian
    '15', #	French
    'A2',	# Ancient Hebrew
    'A1',	# Ancient Greek
    'Q3', #	English
  ].freeze

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
