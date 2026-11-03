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

  SKE_STANDARD_COURSES = [
    '11', # Computing
    '16', # English as a second or other language
    'F0', # Science
    'F3', # Physics
  ].freeze

  SKE_LANGUAGE_COURSES = [
    '15', # French
    '17', # German
    '18', # Italian
    '19', # Japanese
    '20', # Mandarin
    '21', # Russian
    '22', # Spanish
    '24', # Modern languages (other)
  ].freeze

  SKE_PHYSICS_COURSES = [
    'F0', # Physics
    'F3', # Science
  ].freeze
end
