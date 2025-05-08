class ProviderInterface::FindCandidates::OtherQualificationsComponent < ViewComponent::Base
  attr_accessor :application_form
  def initialize(application_form)
    @application_form = application_form
  end

  def head
    [
      t('.qualification'),
      t('.subject'),
      t('.country'),
      { text: t('.year'), numeric: true },
      t('.grade'),
    ]
  end

  def rows
    qualifications.map do |qualification|
      [
        qualification_type(qualification),
        qualification_subject(qualification),
        country(qualification),
        { text: qualification.award_year, numeric: true },
        grade(qualification),
      ]
    end
  end

private

  def qualification_type(qualification)
    qualification.other_uk_qualification_type.presence || qualification.non_uk_qualification_type
  end

  def qualification_subject(qualification)
    qualification.subject&.titleize || t('.not_entered')
  end

  def country(qualification)
    if qualification.international? || qualification.non_uk_qualification_type?
      COUNTRIES_AND_TERRITORIES[qualification.institution_country]
    else
      t('.united_kingdom')
    end
  end

  def grade(qualification)
    if qualification.predicted_grade?
      t('.predicted_grade', predicted_grade: qualification.grade)
    else
      qualification.grade.presence
    end
  end

  def qualifications
    @qualifications ||= application_form.application_qualifications.other
  end
end
