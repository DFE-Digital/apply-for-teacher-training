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
    award_year
  ].freeze

  EXPECTED_INTERNATIONAL_OTHER_QUALIFICATION_DATA = %i[
    qualification_type
    non_uk_qualification_type
    institution_country
    award_year
  ].freeze

  belongs_to :application_form, touch: true

  scope :degrees, -> { where level: 'degree' }
  scope :gcses, -> { where level: 'gcse' }

  enum level: {
    degree: 'degree',
    gcse: 'gcse',
    other: 'other',
  }

  enum comparable_uk_degree: {
    bachelor_ordinary_degree: 'bachelor_ordinary_degree',
    bachelor_honours_degree: 'bachelor_honours_degree',
    postgraduate_certificate_or_diploma: 'postgraduate_certificate_or_diploma',
    masters_degree: 'masters_degree',
    doctor_of_philosophy: 'doctor_of_philosophy',
    post_doctoral_award: 'post_doctoral_award',
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

    case qualification_type
    when 'non_uk'
      return true if EXPECTED_INTERNATIONAL_OTHER_QUALIFICATION_DATA.any? do |field_name|
        send(field_name).blank?
      end
    else
      return true if EXPECTED_OTHER_QUALIFICATION_DATA.any? do |field_name|
        send(field_name).blank?
      end
    end

    false
  end

  def naric_reference_choice
    if naric_reference.present?
      'Yes'
    elsif naric_reference.nil? && grade.present?
      'No'
    end
  end

  def set_grade
    case grade
    when 'n/a'
      'not_applicable'
    when 'unknown'
      'unknown'
    else
      'other'
    end
  end

  def set_other_grade
    grade if grade != 'n/a' && grade != 'unknown'
  end

  def completed?
    !predicted_grade?
  end
end
