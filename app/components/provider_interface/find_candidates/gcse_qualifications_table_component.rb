class ProviderInterface::FindCandidates::GcseQualificationsTableComponent < ViewComponent::Base
  include ViewHelper
  include GcseQualificationHelper

  attr_accessor :application_form
  delegate :maths_gcse, :english_gcse, :science_gcse, to: :application_form

  def initialize(application_form)
    @application_form = application_form
  end

  def gcse_rows
    row = Struct.new(
      :qualification_type,
      :qualification_subject,
      :country,
      :year_awarded,
      :grades,
      :enic_text,
      :missing_text,
    )

    [maths_gcse, english_gcse, science_gcse].map do |qualification|
      next if qualification.blank?

      row.new(
        qualification_type: qualification_type(qualification),
        qualification_subject: qualification_subject(qualification),
        country: country(qualification),
        year_awarded: year_awarded(qualification),
        grades: grades(qualification),
        enic_text: enic_text(qualification),
        missing_text: missing_qualification_text(qualification),
      )
    end.compact
  end

  def qualification_type(qualification)
    if qualification.other_uk_qualification_type.present?
      qualification.other_uk_qualification_type
    elsif qualification.non_uk_qualification_type.present?
      qualification.non_uk_qualification_type
    elsif qualification.currently_completing_qualification || qualification.missing_explanation.present?
      t('.no_qualification_yet')
    else
      t('.gcse')
    end
  end

  def qualification_subject(qualification)
    if [ApplicationQualification::SCIENCE_SINGLE_AWARD,
        ApplicationQualification::SCIENCE_DOUBLE_AWARD,
        ApplicationQualification::SCIENCE_TRIPLE_AWARD].include? qualification.subject
      t('.science')
    else
      qualification.subject.capitalize
    end
  end

  def country(qualification)
    if qualification.non_uk_qualification_type.present?
      CountryFinder.find_name_from_iso_code(qualification.institution_country)
    else
      t('.united_kingdom')
    end
  end

  def year_awarded(qualification)
    qualification.award_year.presence || t('.not_provided')
  end

  def grades(qualification)
    if qualification.grade.present?
      Array(qualification.grade)
    elsif qualification.constituent_grades.present?
      qualification.constituent_grades.map do |(subject, _details)|
        ApplicationQualificationDecorator.new(qualification).grade_details.fetch(subject)
      end
    else
      Array(t('.not_provided'))
    end
  end

  def enic_text(qualification)
    if qualification.enic_reference.present? && qualification.comparable_uk_qualification.present?
      {
        heading: t('.comparability'),
        text: t('.comparability_enic_statement', reference: qualification.enic_reference, comparable: qualification.comparable_uk_qualification),
      }
    end
  end

  def missing_qualification_text(qualification)
    if qualification.currently_completing_qualification
      {
        heading: t('.currently_studying_heading'),
        text: qualification.not_completed_explanation || t('.no_additional_information_provided'),
      }
    elsif qualification.missing_explanation.present?
      {
        heading: t('.other_evidence_i_have_the_skills'),
        text: qualification.missing_explanation,
      }
    end
  end

  def cell_attributes(row)
    if row.enic_text.present?
      { html_attributes: { class: 'qualifications-table__cell--no-bottom-border' } }
    else
      {}
    end
  end
end
