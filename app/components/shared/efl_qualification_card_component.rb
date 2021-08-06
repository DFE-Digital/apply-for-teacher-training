# NOTE: This component is used by both provider and support UIs
class EflQualificationCardComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def render?
    !application_form.british_or_irish? && english_proficiency.present?
  end

  def english_proficiency
    @english_proficiency ||= application_form.english_proficiency
  end

  def efl_qualification
    @efl_qualification ||= english_proficiency.efl_qualification
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
  delegate :no_qualification_details, to: :english_proficiency
end
