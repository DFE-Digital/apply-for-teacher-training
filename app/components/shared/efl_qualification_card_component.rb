# NOTE: This component is used by both provider and support UIs
class EflQualificationCardComponent < ApplicationComponent
  include QualificationCardHelper

  attr_reader :application_form, :header_tag

  def initialize(application_form, header_tag: 'h4')
    @application_form = application_form
    @header_tag = header_tag
  end

  def render?
    !application_form.british_or_irish? && english_proficiency.present?
  end

  def english_proficiency
    # what about the feature flag?
    @english_proficiency ||= application_form.published_english_proficiencies.first
  end

  def efl_qualification
    @efl_qualification ||= english_proficiency.efl_qualification
  end

  # def qualification_status
  #   if english_proficiency.has_qualification == true
  #     'Candidate has done an English as a foreign language assessment.'
  #   elsif english_proficiency.no_qualification_details.nil?
  #     'Candidate does not plan to do an English as a foreign language assessment.'
  #   elsif english_proficiency.no_qualification_details.present?
  #     'Candidate plans to do an English as a foreign language assessment.'
  #   elsif english_proficiency.qualification_not_needed == true
  #     'Candidate said that English is not a foreign language to them.'
  #   end
  # end
  #

  def statuses
    content = []

    if qualification_not_needed == true
      content << 'Candidate said that English is not a foreign language to them.'
    end

    if has_qualification == true
      content << 'Candidate has done an English as a foreign language assessment.'
    elsif no_qualification == true
      content << 'Candidate does not plan to do an English as a foreign language assessment.'
    elsif no_qualification_details.present?
      content << 'Candidate plans to do an English as a foreign language assessment.'
    elsif degree_taught_in_english == true
      content << 'Candidate has not done an English as a foreign language assessment yet.'
    end

    content
  end

  def grade_title
    case english_proficiency.efl_qualification_type
    when 'IeltsQualification'
      'Overall band score'
    when 'ToeflQualification'
      'Total score'
    else
      'Score or grade'
    end
  end

  def reference_number_title
    case english_proficiency.efl_qualification_type
    when 'IeltsQualification'
      'TRF number'
    when 'ToeflQualification'
      'Registration number'
    end
  end

  delegate :name, :award_year, :grade, :unique_reference_number, to: :efl_qualification
  delegate(
    :no_qualification_details,
    :has_qualification,
    :no_qualification,
    :qualification_not_needed,
    :degree_taught_in_english,
    to: :english_proficiency,
  )
end
