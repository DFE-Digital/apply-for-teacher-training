class CandidateInterface::EnglishForeignLanguage::SummaryListReviewComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def efl_rows
    [
      assessment_type,
      assessment_identifier,
      grade,
      award_year,
    ].compact
  end

private

  def assessment_type
    {
      key: { text: 'Type of assessment' },
      value: { text: qualification.name },
    }
  end

  def assessment_identifier
    return if qualification.is_a?(OtherEflQualification)

    case qualification.name
    when 'IELTS'
      {
        key: { text: 'Test Report Form (TRF) number' },
        value: { text: qualification.trf_number },
      }
    when 'TOEFL'
      {
        key: { text: 'TOEFL registration number' },
        value: { text: qualification.registration_number },
      }
    end
  end

  def grade
    case qualification.name
    when 'IELTS'
      {
        key: { text: 'Overall band score' },
        value: { text: qualification.band_score },
      }
    when 'TOEFL'
      {
        key: { text: 'Total score' },
        value: { text: qualification.total_score },
      }
    else
      {
        key: { text: 'Score or grade' },
        value: { text: qualification.grade },
      }
    end
  end

  def award_year
    {
      key: { text: 'Year completed' },
      value: { text: qualification.award_year },
    }
  end

  def qualification
    application_form.english_proficiency.efl_qualification
  end
end
