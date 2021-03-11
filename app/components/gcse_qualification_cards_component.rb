# NOTE: This component is used by both provider and support UIs
class GcseQualificationCardsComponent < ViewComponent::Base
  include ApplicationHelper
  include ViewHelper

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
    if [ApplicationQualification::SCIENCE_SINGLE_AWARD,
        ApplicationQualification::SCIENCE_DOUBLE_AWARD,
        ApplicationQualification::SCIENCE_TRIPLE_AWARD].include? qualification.subject
      'Science'
    else
      qualification.subject.capitalize
    end
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
      t("application_form.gcse.qualification_types.#{qualification.qualification_type}", default: qualification.qualification_type)
    end
  end

  def enic_statement(qualification)
    if qualification.enic_reference.present? && qualification.comparable_uk_qualification.present?
      "#{t("service_name.enic.short_name")} statement #{qualification.enic_reference} says this is comparable to a #{qualification.comparable_uk_qualification}."
    end
  end

  def grade_details(qualification)
    case qualification.subject
    when ApplicationQualification::SCIENCE_TRIPLE_AWARD
      grades = qualification.constituent_grades
      [
        "#{grades['biology']['grade']} (Biology)",
        "#{grades['chemistry']['grade']} (Chemistry)",
        "#{grades['physics']['grade']} (Physics)",
      ]
    when ApplicationQualification::SCIENCE_DOUBLE_AWARD
      ["#{qualification.grade} (Double award)"]
    when ApplicationQualification::SCIENCE_SINGLE_AWARD
      ["#{qualification.grade} (Single award)"]
    when ->(_n) { qualification.constituent_grades }
      present_constituent_grades(qualification)
    else
      [qualification.grade]
    end
  end

  def present_constituent_grades(qualification)
    grades = qualification.constituent_grades
    grades.map do |k, v,|
      grade = v['grade']
      case k
      when 'english_single_award'
        "#{grade} (English Single award)"
      when 'english_double_award'
        "#{grade} (English Double award)"
      when 'english_studies_single_award'
        "#{grade} (English Studies Single award)"
      when 'english_studies_double_award'
        "#{grade} (English Studies Double award)"
      else
        "#{grade} (#{k.humanize.titleize})"
      end
    end
  end

  def in_support_console?
    current_namespace == 'support_interface'
  end
end
