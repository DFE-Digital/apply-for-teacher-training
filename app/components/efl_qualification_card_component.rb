class EflQualificationCardComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def render?
    !application_form.english_speaking_nationality? && english_proficiency.present?
  end

  def english_proficiency
    @english_proficiency ||= application_form.english_proficiency
  end

  def efl_qualification
    @efl_qualification ||= english_proficiency.efl_qualification
  end

  def qualification_status
    if english_proficiency.has_qualification?
      'Candidate has an English as a foreign language qualification.'
    elsif english_proficiency.no_qualification?
      'Candidate does not have an English as a foreign language qualification yet.'
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
