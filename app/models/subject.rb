class Subject < ApplicationRecord
  has_many :course_subjects
  has_many :courses, through: :course_subjects

  validates :code, uniqueness: true

  SUBJECTS = %i[
    art_and_design
    biology
    business_studies
    chemistry
    classics
    computing
    design_and_technology
    drama
    english
    geography
    history
    mathematics
    modern_foreign_languages
    music
    other
    physical_education
    physics
    religious_education
    stem
    ebacc
    primary
    secondary
  ].freeze

  STEM_SUBJECTS = %i[
    mathematics
    biology
    chemistry
    physics
    computing
  ].freeze

  EBACC_SUBJECTS = %i[
    english
    mathematics
    biology
    chemistry
    physics
    computing
    geography
    history
    modern_foreign_languages
    classics
  ].freeze

  SECONDARY_SUBJECTS = %i[
    art_and_design
    biology
    business_studies
    chemistry
    classics
    computing
    design_and_technology
    drama
    english
    geography
    history
    mathematics
    modern_foreign_languages
    music
    other
    physical_education
    physics
    religious_education
  ].freeze
end
