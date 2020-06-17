class ApplicationQualification < ApplicationRecord
  EXPECTED_DEGREE_FIELDS = %i[
    qualification_type
    subject
    predicted_grade
    start_year
    award_year
    institution_name
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

    EXPECTED_DEGREE_FIELDS.each do |field|
      if send(field).nil?
        return true
      end
    end

    false
  end
end
