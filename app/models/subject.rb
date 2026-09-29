class Subject < ApplicationRecord
  has_many :course_subjects, dependent: nil
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

  SKE_STANDARD_COURSES = [].freeze

  SKE_LANGUAGE_COURSES = %w[].freeze

  SKE_PHYSICS_COURSES = %w[].freeze
end
