class ProviderInterface::FindCandidates::DegreesTableComponent < ApplicationComponent
  attr_accessor :application_form
  def initialize(application_form)
    @application_form = application_form
  end

  def degree_rows
    degree_row = Struct.new(:degree_type, :degree_subject, :issued_by, :year_range, :grade, :enic_text)
    degrees.map do |degree|
      degree_row.new(
        degree_type: degree_type(degree),
        degree_subject: degree_subject(degree),
        issued_by: issued_by(degree),
        year_range: year_range(degree),
        grade: grade(degree),
        enic_text: enic_text(degree),
      )
    end
  end

  def degree_type(degree)
    name = Hesa::DegreeType.find_by_name(degree.qualification_type)&.abbreviation || degree.qualification_type

    if degree.grade&.include? 'honours'
      "#{name} (Hons)"
    else
      name
    end
  end

  def degree_subject(degree)
    degree.subject
  end

  def issued_by(degree)
    if degree.international?
      "#{degree.institution_name}, #{CountryFinder.find_name_from_iso_code(degree.institution_country)}"
    else
      degree.institution_name
    end
  end

  def year_range(degree)
    "#{degree.start_year} to #{degree.award_year}"
  end

  def grade(degree)
    if degree.predicted_grade?
      "Predicted: #{degree.grade}"
    else
      degree.grade
    end
  end

  def enic_text(degree)
    if degree.enic_reference.present? && degree.comparable_uk_degree.present?
      degree_name = t("application_form.degree.comparable_uk_degree.values.#{degree.comparable_uk_degree}")
      "#{t('service_name.enic.short_name_with_naric')} statement #{degree.enic_reference} says this is comparable to a #{degree_name}"
    end
  end

  def degrees
    @degrees ||= application_form.degree_qualifications
  end

  def cell_attributes(row)
    if row.enic_text.present?
      { html_attributes: { class: 'qualifications-table__cell--no-bottom-border' } }
    else
      {}
    end
  end
end
