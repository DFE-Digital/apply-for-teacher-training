class CandidateInterface::EnglishForeignLanguage::SummaryReviewComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def efl_rows
    if application_form.english_proficiency.has_qualification?
      [
        assessment_type,
        assessment_identifier,
        grade,
        award_year,
      ].compact
    else
      [
        do_you_have_a_qualification_row,
      ]
    end
  end

private

  def assessment_type
    {
      key: t('.type'),
      value: qualification.name,
    }
  end

  def assessment_identifier
    return if qualification.is_a?(OtherEflQualification)

    case qualification.name
    when 'IELTS'
      {
        key: t('.trf'),
        value: qualification.trf_number,
      }
    when 'TOEFL'
      {
        key: t('.toefl_registration'),
        value: qualification.registration_number,
      }
    end
  end

  def grade
    case qualification.name
    when 'IELTS'
      {
        key: t('.band_score'),
        value: qualification.band_score,
      }
    when 'TOEFL'
      {
        key: t('.total_score'),
        value: qualification.total_score,
      }
    else
      {
        key: t('.grade'),
        value: qualification.grade,
      }
    end
  end

  def award_year
    {
      key: t('.award_year'),
      value: qualification.award_year,
    }
  end

  def do_you_have_a_qualification_row
    {
      key: t('.have_you_done_assessment'),
      value: summary,
    }
  end

  def summary
    if application_form.english_proficiency.qualification_not_needed?
      t('.not_foreign_language')
    else
      [
        tag.p(t('.no_assessment'), class: 'govuk-body'),
        tag.p(application_form.english_proficiency.no_qualification_details, class: 'govuk-body'),
      ].join.html_safe
    end
  end

  def qualification
    application_form.english_proficiency.efl_qualification
  end
end
