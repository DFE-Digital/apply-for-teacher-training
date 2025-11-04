# NOTE: This component is used by both provider and support UIs
class DegreeQualificationCardsComponent < ViewComponent::Base
  include ViewHelper
  include QualificationCardHelper

  attr_reader :degrees, :application_choice_state, :show_hesa_codes, :header_tag

  alias show_hesa_codes? show_hesa_codes

  def initialize(degrees, application_choice_state: nil, show_hesa_codes: false, editable: false, header_tag: 'h4')
    @degrees = degrees
    @application_choice_state = application_choice_state
    @show_hesa_codes = show_hesa_codes
    @editable = editable
    @header_tag = header_tag
  end

  def section_title
    'Degree'.pluralize(degrees.count)
  end

  def degree_type_and_subject(degree)
    "#{degree_type_with_honours(degree)} #{degree.subject}"
  end

  def formatted_grade(degree)
    if degree.predicted_grade?
      "Predicted: #{degree.grade}"
    else
      degree.grade
    end
  end

  def formatted_institution(degree)
    degree.international? ? institution_and_country(degree) : institution(degree)
  end

  def enic(degree)
    if degree.enic_reference.present? && degree.comparable_uk_degree.present?
      degree_name = t("application_form.degree.comparable_uk_degree.values.#{degree.comparable_uk_degree}")
      "#{t('service_name.enic.short_name_with_naric')} statement #{degree.enic_reference} says this is comparable to a #{degree_name}"
    end
  end

  def hesa_code_values(degree)
    {
      'Type' => degree.qualification_type_hesa_code,
      'Subject' => degree.subject_hesa_code,
      'Establishment' => degree.institution_hesa_code,
      'Class' => degree.grade_hesa_code,
    }
  end

private

  def degree_type_with_honours(degree)
    if degree.grade&.include? 'honours'
      "#{abbreviate_degree(degree.qualification_type)} (Hons)"
    else
      abbreviate_degree(degree.qualification_type)
    end
  end

  def abbreviate_degree(name)
    Hesa::DegreeType.find_by_name(name)&.abbreviation || name
  end

  def institution_and_country(degree)
    "#{institution(degree)}, #{CountryFinder.find_name_from_iso_code(degree.institution_country)}"
  end

  def institution(degree)
    degree.institution_name
  end

  def editable?
    @editable
  end
end
