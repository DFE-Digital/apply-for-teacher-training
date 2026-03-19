# NOTE: This component is used by both provider and support UIs
class EflQualificationCardComponent < ApplicationComponent
  include QualificationCardHelper

  attr_reader :application_form, :header_tag

  def initialize(application_form, header_tag: 'h4')
    @application_form = application_form
    @header_tag = header_tag
  end

  def render?
    !application_form.british_or_irish? && english_proficiencies.present?
  end

  def english_proficiencies
    @english_proficiencies ||= application_form.english_proficiencies
  end

  def qualification_status(proficiency_record)
    if proficiency_record.has_qualification?
      'Candidate has done an English as a foreign language assessment.'
    elsif proficiency_record.no_qualification? && no_qualification_details.nil?
      'Candidate does not plan to do an English as a foreign language assessment.'
    elsif proficiency_record.no_qualification?
      'Candidate has not done an English as a foreign language assessment yet.'
    elsif proficiency_record.qualification_not_needed?
      'Candidate said that English is not a foreign language to them.'
    end
  end

  def grade_title(proficiency_record)
    case proficiency_record.efl_qualification_type
    when 'IeltsQualification'
      'Overall band score'
    when 'ToeflQualification'
      'Total score'
    else
      'Score or grade'
    end
  end

  def reference_number_title(proficiency_record)
    case proficiency_record.efl_qualification_type
    when 'IeltsQualification'
      'TRF number'
    when 'ToeflQualification'
      'Registration number'
    end
  end

  # delegate :name, :award_year, :grade, :unique_reference_number, to: :efl_qualification
  # delegate :no_qualification_details, to: :english_proficiency
end
