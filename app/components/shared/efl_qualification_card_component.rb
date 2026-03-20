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
    @english_proficiency ||= if FeatureFlag.active?('2027_application_form_has_many_english_proficiencies')
                               application_form.published_english_proficiencies.first
                             else
                               application_form.english_proficiency
                             end
  end

  def efl_qualification
    @efl_qualification ||= english_proficiency.efl_qualification
  end

  def qualification_statuses
    if FeatureFlag.active?('2027_application_form_has_many_english_proficiencies')
      statuses
    else
      [qualification_status]
    end
  end

  def statuses
    content = []

    if qualification_not_needed
      content << 'Candidate said that English is not a foreign language to them.'
    end

    if has_qualification
      content << 'Candidate has done an English as a foreign language assessment.'
    end

    return content if qualification_not_needed || has_qualification

    content << if no_qualification_details.present?
                 'Candidate plans to do an English as a foreign language assessment.'
               else
                 'Candidate does not plan to do an English as a foreign language assessment.'
               end

    content
  end

  def qualification_status
    if english_proficiency.has_qualification?
      'Candidate has done an English as a foreign language assessment.'
    elsif english_proficiency.no_qualification?
      'Candidate has not done an English as a foreign language assessment yet.'
    else
      'Candidate said that English is not a foreign language to them.'
    end
  end

  def qualification?
    if FeatureFlag.active?('2027_application_form_has_many_english_proficiencies')
      english_proficiency.has_qualification
    else
      english_proficiency.has_qualification?
    end
  end

  def no_qualification?
    if FeatureFlag.active?('2027_application_form_has_many_english_proficiencies')
      no_qualification_details.present?
    else
      english_proficiency.no_qualification?
    end
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
    :qualification_not_needed,
    to: :english_proficiency,
  )
end
