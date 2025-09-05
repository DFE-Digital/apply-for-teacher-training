# NOTE: This component is used by both provider and support UIs
class GcseQualificationCardsComponent < ApplicationComponent
  include ViewHelper
  include GcseQualificationHelper

  attr_reader :application_form

  def initialize(application_form, editable: false)
    @application_form = application_form
    @editable = editable
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
    if [ApplicationQualification::SCIENCE_SINGLE_AWARD,
        ApplicationQualification::SCIENCE_DOUBLE_AWARD,
        ApplicationQualification::SCIENCE_TRIPLE_AWARD].include? qualification.subject
      'Science'
    else
      qualification.subject.capitalize
    end
  end

  def institution_country(qualification)
    CountryFinder.find_name_from_iso_code(qualification.institution_country)
  end

  def presentable_qualification_type(qualification)
    if qualification.other_uk_qualification_type.present?
      qualification.other_uk_qualification_type
    elsif qualification.non_uk_qualification_type.present?
      qualification.non_uk_qualification_type
    else
      t("application_form.gcse.qualification_types.#{qualification.qualification_type}", default: qualification.qualification_type)
    end
  end

  def enic_statement(qualification)
    if qualification.enic_reference.present? && qualification.comparable_uk_qualification.present?
      "#{t('service_name.enic.short_name_with_naric')} statement #{qualification.enic_reference} says this is comparable to a #{qualification.comparable_uk_qualification}."
    end
  end

  def grade_details(qualification)
    ApplicationQualificationDecorator.new(qualification).grade_details
  end

  def editable?
    @editable
  end
end
