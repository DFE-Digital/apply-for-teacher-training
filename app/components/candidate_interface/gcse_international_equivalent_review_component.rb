module CandidateInterface
  class GcseInternationalEquivalentReviewComponent < ApplicationComponent
    include GcseStatementComparabilityPathHelper
    include EnicReasonTranslationHelper

    def initialize(application_form:, application_qualification:, subject:, editable: true, heading_level: 2, submitting_application: false, return_to_application_review: true)
      @application_form = application_form
      @application_qualification = application_qualification
      @subject = subject
      @editable = editable
      @heading_level = heading_level
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def gcse_qualification_rows
      [
        type_row,
        country_row,
        qualification_row,
        grade_row,
        enic_statement_row,
        enic_reference_row,
        comparable_uk_qualification_row,
        grade_explanation_row,
        award_year_row,
      ].compact
    end

    def render?
      application_qualification.present?
    end

  private

    attr_reader :application_qualification, :subject

    def section_or_gcse_incomplete?
      gcse_completed = "#{@subject}_gcse_completed"
      (!@application_form.send(gcse_completed) || @application_form.send("#{@subject}_gcse")&.incomplete_gcse_information?) && !@application_qualification&.missing_qualification?
    end

    def type_row
      {
        key: t('application_form.gcse.qualification_type.label'),
        value: 'Qualification from outside the UK',
        action: {
          href: candidate_interface_gcse_details_edit_type_path(change_path_params),
          visually_hidden_text: 'qualification from outside the UK',
        },
        html_attributes: {
          data: {
            qa: "gcse-#{subject}-qualification",
          },
        },
      }
    end

    def qualification_row
      {
        key: t('application_form.gcse.qualification.label'),
        value: application_qualification.non_uk_qualification_type || govuk_link_to('Enter your qualification', candidate_interface_gcse_new_international_flow_edit_qualifications_path(change_path_params)),
      }.tap do |row|
        if application_qualification.non_uk_qualification_type
          row[:action] = {
            href: candidate_interface_gcse_new_international_flow_edit_qualifications_path(change_path_params),
            visually_hidden_text: "qualification for #{application_qualification.non_uk_qualification_type}, #{subject}",
          }
          row[:html_attributes] = {
            data: {
              qa: "gcse-#{subject}-qualification",
            },
          }
        end
      end
    end

    def award_year_row
      return nil if application_qualification.grade.nil?

      {
        key: 'Year awarded',
        value: application_qualification.award_year || govuk_link_to('Enter the year the qualification was awarded', candidate_interface_gcse_new_international_flow_edit_year_path(change_path_params)),
      }.tap do |row|
        if application_qualification.award_year
          row[:action] = {
            href: candidate_interface_gcse_new_international_flow_edit_year_path(change_path_params),
            visually_hidden_text: "year awarded for #{application_qualification.non_uk_qualification_type}, #{subject}",
          }
        end
      end
    end

    def grade_row
      return nil if application_qualification.non_uk_qualification_type.blank? || application_qualification.institution_country.blank?

      {
        key: 'Grade',
        value: application_qualification.grade || govuk_link_to('Enter your grade', grade_link_value),
      }.tap do |row|
        if application_qualification.grade
          row[:action] = {
            href: grade_link_value,
            visually_hidden_text: "grade for #{application_qualification.non_uk_qualification_type}, #{subject}",
          }
        end
      end
    end

    def grade_link_value
      inspect_grade.requires_grade_schema_selection? ? candidate_interface_gcse_new_international_flow_edit_grade_schemas_path(change_path_params) : candidate_interface_gcse_new_international_flow_edit_grades_path(change_path_params)
    end

    def grade_explanation_row
      return nil if application_qualification.grade.nil? || application_qualification.enic_reason.present?
        || !inspect_grade.likely_below?

      {
        key: "Evidence that your #{capitalize_english(subject)} skills are at GCSE grade 4 (C) or above",
        value: application_qualification.not_completed_explanation || govuk_link_to("Enter evidence that your #{capitalize_english(subject)} skills are at GCSE grade 4 (C) or above", candidate_interface_gcse_new_international_flow_interruption_path(change_path_params)),
      }.tap do |row|
        if application_qualification.not_completed_explanation
          row[:action] = {
            href: candidate_interface_gcse_new_international_flow_interruption_path(change_path_params),
            visually_hidden_text: "Evidence that your #{subject} skills are at GCSE grade 4 (C) or above",
          }
        end
      end
    end

    def country_row
      return nil unless application_qualification.qualification_type == 'non_uk'

      {
        key: 'Country or territory',
        value: country_value,
      }.tap do |row|
        if application_qualification.institution_country
          row[:action] =
            {
              href: candidate_interface_gcse_new_international_flow_edit_institution_country_path(change_path_params),
              visually_hidden_text: 'the country that you studied in',
            }
        end
      end
    end

    def country_value
      if application_qualification.institution_country
        CountryFinder.find_name_from_iso_code(application_qualification.institution_country)
      else
        govuk_link_to("Enter the country or territory where you studied for your #{capitalize_english(subject)} qualification", candidate_interface_gcse_new_international_flow_edit_institution_country_path(change_path_params))
      end
    end

    def enic_statement_row
      return nil if (application_qualification.not_completed_explanation.present? && inspect_grade.likely_below?)
        || application_qualification.grade.nil?

      {
        key: t('application_form.gcse.enic_statement.review_label'),
        value: enic_statement_value,
      }.tap do |row|
        if application_qualification.enic_reason?
          row[:action] =
            {
              href: inspect_grade.likely_below? ? candidate_interface_gcse_new_international_flow_interruption_path(change_path_params) : candidate_interface_gcse_new_international_flow_edit_enic_path(change_path_params),
              visually_hidden_text: t('application_form.gcse.enic_statement.change_action'),
            }
        end
      end
    end

    def enic_statement_value
      if application_qualification.enic_reason.nil?
        govuk_link_to('Enter your ENIC status', inspect_grade.likely_below? ? candidate_interface_gcse_new_international_flow_interruption_path(change_path_params) : candidate_interface_gcse_new_international_flow_edit_enic_path(change_path_params))
      else
        t("gcse_edit_enic.#{application_qualification.enic_reason}")
      end
    end

    def enic_reference_row
      return nil unless application_qualification.enic_reason_obtained?
      return nil if application_qualification.not_completed_explanation.present?

      {
        key: t('application_form.gcse.enic_reference.review_label'),
        value: enic_reference_value,
        html_attributes: {
          data: {
            qa: 'gcse-enic-reference',
          },
        },
      }.tap do |row|
        if application_qualification.enic_reference
          row[:action] =
            {
              href: edit_international_flow_statement_comparability_path(change_path_params[:subject]),
              visually_hidden_text: t('application_form.gcse.enic_reference.change_action'),
            }
        end
      end
    end

    def enic_reference_value
      application_qualification.enic_reference.presence || govuk_link_to('Enter your UK ENIC reference number', edit_international_flow_statement_comparability_path(change_path_params[:subject]))
    end

    def comparable_uk_qualification_row
      return nil unless application_qualification.enic_reference
      return nil if application_qualification.not_completed_explanation.present?

      {
        key: t('application_form.gcse.comparable_uk_qualification.review_label'),
        value: application_qualification.comparable_uk_qualification,
        action: {
          href: edit_international_flow_statement_comparability_path(change_path_params[:subject]),
          visually_hidden_text: t('application_form.gcse.comparable_uk_qualification.change_action'),
        },
        html_attributes: {
          data: {
            qa: 'gcse-comparable-uk-qualification',
          },
        },
      }
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end

    def change_path_params
      params = { subject: }
      if @return_to_application_review
        params.merge(return_to_params)
      else
        params
      end
    end

    def capitalize_english(subject)
      subject == 'english' ? 'English' : subject
    end

    def inspect_grade
      InspectInternationalGcseGrade.new(application_qualification)
    end
  end
end
