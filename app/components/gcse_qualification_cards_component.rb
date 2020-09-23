class GcseQualificationCardsComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def maths
    application_form.maths_gcse
  end

  def english
    application_form.english_gcse
  end

  def science
    application_form.science_gcse
  end

  def candidate_does_not_have
    'Candidate does not have this qualification yet'
  end

  def subject(qualification)
    qualification.subject.capitalize
  end

  def institution_country(qualification)
    COUNTRIES[qualification.institution_country]
  end

  def presentable_qualification_type(qualification)
    if qualification.other_uk_qualification_type.present?
      qualification.other_uk_qualification_type
    elsif qualification.non_uk_qualification_type.present?
      qualification.non_uk_qualification_type
    else
      I18n.t("application_form.gcse.qualification_types.#{qualification.qualification_type}", default: qualification.qualification_type)
    end
  end

  def naric_statement(qualification)
    if qualification.naric_reference.present? && qualification.comparable_uk_qualification.present?
      "NARIC statement #{qualification.naric_reference} says this is comparable to a #{qualification.comparable_uk_qualification}."
    end
  end
end
