class ApplicationQualification < ApplicationRecord
  EXPECTED_DEGREE_DATA = %i[
    qualification_type
    subject
    institution_name
    grade
    start_year
    award_year
  ].freeze

  EXPECTED_OTHER_QUALIFICATION_DATA = %i[
    qualification_type
    subject
    grade
    institution_name
    award_year
  ].freeze

  belongs_to :application_form, touch: true

  scope :degrees, -> { where level: 'degree' }
  scope :gcses, -> { where level: 'gcse' }
  scope :other, -> { where level: 'other' }

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }

  audited associated_with: :application_form

  def missing_qualification?
    qualification_type == 'missing'
  end

  def incomplete_degree_information?
    return false unless degree?
    return true if predicted_grade.nil?

    return true if EXPECTED_DEGREE_DATA.any? do |field_name|
      send(field_name).blank?
    end

    false
  end

  def incomplete_other_qualification?
    return false unless other?

    EXPECTED_OTHER_QUALIFICATION_DATA.any? do |field_name|
      send(field_name).blank?
    end
  end
end
