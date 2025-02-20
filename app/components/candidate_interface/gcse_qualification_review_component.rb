module CandidateInterface
  class GcseQualificationReviewComponent < ViewComponent::Base
    include GcseQualificationHelper
    include GcseStatementComparabilityPathHelper
    include EnicReasonTranslationHelper

    def initialize(application_form:, application_qualification:, subject:, editable: true, heading_level: 2, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @application_qualification = application_qualification
      @subject = subject
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def gcse_qualification_rows
      if application_qualification.missing_qualification?
        [
          missing_qualifiation_type_row,
          not_completed_explanation_row,
          missing_explanation_for_no_gcse_row,
        ].compact
      else
        [
          qualification_row,
          country_row,
          enic_statement_row,
          enic_reference_row,
          comparable_uk_qualification_row,
          grade_row,
          award_year_row,
          failing_grade_explanation_row,
          missing_explanation_for_gcse_row,
        ].compact
      end
    end

    def show_missing_banner?
      if @submitting_application
        gcse_completed = "#{@subject}_gcse_completed"
        !@application_form.send(gcse_completed) && @editable
      end
    end

    def show_values_missing_banner?
      if @submitting_application
        section_or_gcse_incomplete? && @editable
      end
    end

  private

    attr_reader :application_qualification, :subject

    def section_or_gcse_incomplete?
      gcse_completed = "#{@subject}_gcse_completed"
      (!@application_form.send(gcse_completed) || @application_form.send("#{@subject}_gcse")&.incomplete_gcse_information?) && !@application_qualification&.missing_qualification?
    end

    def qualification_row
      {
        key: t('application_form.gcse.qualification.label'),
        value: gcse_qualification_types[application_qualification.qualification_type.to_sym.downcase],
        action: {
          href: candidate_interface_gcse_details_edit_type_path(change_path_params),
          visually_hidden_text: "qualification for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        },
        html_attributes: {
          data: {
            qa: "gcse-#{subject}-qualification",
          },
        },
      }
    end

    def award_year_row
      {
        key: 'Year awarded',
        value: application_qualification.award_year || govuk_link_to('Enter the year the qualification was awarded', candidate_interface_gcse_details_edit_year_path),
      }.tap do |row|
        if application_qualification.award_year
          row[:action] = {
            href: candidate_interface_gcse_details_edit_year_path(change_path_params),
            visually_hidden_text: "year awarded for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
          }
        end
      end
    end

    def grade_row
      {
        key: 'Grade',
        value: present_grades || govuk_link_to('Enter your grade', grade_edit_path),
      }.tap do |row|
        if application_qualification.grade || application_qualification.constituent_grades
          row[:action] = {
            href: grade_edit_path,
            visually_hidden_text: "grade for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
          }
        end
      end
    end

    def failing_grade_explanation_row
      return nil unless application_qualification.failed_required_gcse?

      {
        key: 'Are you currently studying to retake this qualification?',
        value: failing_grade_row_value(application_qualification),
        action: {
          href: candidate_interface_gcse_details_edit_grade_explanation_path(change_path_params),
          visually_hidden_text: 'if you are working towards this qualification at grade 4 (C) or above, give us details',
        },
        html_attributes: {
          data: {
            qa: 'gcse-failing-grade-explanation',
          },
        },
      }
    end

    def present_grades
      case application_qualification.subject
      when ApplicationQualification::SCIENCE_TRIPLE_AWARD
        grades = application_qualification.constituent_grades
        [
          "#{grades['biology']['grade']} (Biology)",
          "#{grades['chemistry']['grade']} (Chemistry)",
          "#{grades['physics']['grade']} (Physics)",
        ]
      when ApplicationQualification::SCIENCE_DOUBLE_AWARD
        "#{application_qualification.grade} (Double award)"
      when ApplicationQualification::SCIENCE_SINGLE_AWARD
        "#{application_qualification.grade} (Single award)"
      when ->(_n) { application_qualification.constituent_grades }
        present_constituent_grades
      else
        application_qualification.grade
      end
    end

    def present_constituent_grades
      grades = application_qualification.constituent_grades
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

    def missing_qualifiation_type_row
      {
        key: "What type of #{capitalize_english(@subject)} qualification do you have?",
        value: "I don’t have a #{capitalize_english(@subject)} qualification yet",
        action: {
          href: candidate_interface_gcse_details_edit_type_path(change_path_params),
          visually_hidden_text: 'whether you have this qualification',
        },
        html_attributes: {
          data: {
            qa: 'gcse-missing-qualification-type',
          },
        },
      }
    end

    def not_completed_explanation_row
      {
        key: 'Are you currently studying for this qualification?',
        value: not_completed_explanation_value,
      }.tap do |row|
        unless application_qualification.currently_completing_qualification.nil?
          row[:action] = {
            href: candidate_interface_gcse_edit_not_yet_completed_path(change_path_params),
            visually_hidden_text: 'how you expect to gain this qualification',
          }
        end
      end
    end

    def not_completed_explanation_value
      if application_qualification.currently_completing_qualification.nil?
        govuk_link_to('Select if you are currently studying for this qualification', candidate_interface_gcse_edit_not_yet_completed_path(change_path_params))
      else
        not_completed_explanation_value_row(application_qualification)
      end
    end

    def missing_explanation_for_no_gcse_row
      missing_explanation_row if !application_qualification.currently_completing_qualification
    end

    def missing_explanation_for_gcse_row
      missing_explanation_row if application_qualification.failed_required_gcse? && !application_qualification.currently_completing_qualification
    end

    def missing_explanation_row
      {
        key: 'Other evidence I have the skills required (optional)',
        value: application_qualification.missing_explanation.presence || govuk_link_to('Enter other evidence', candidate_interface_gcse_edit_missing_path(change_path_params)),
      }.tap do |row|
        if application_qualification.missing_explanation
          row[:action] =
            {
              href: candidate_interface_gcse_edit_missing_path(change_path_params),
              visually_hidden_text: 'evidence of meeting the required standard',
            }
        end
      end
    end

    def gcse_qualification_types
      t('application_form.gcse.qualification_types').merge(
        other_uk: application_qualification.other_uk_qualification_type,
        non_uk: application_qualification.non_uk_qualification_type,
      )
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
              href: candidate_interface_gcse_details_edit_institution_country_path(change_path_params),
              visually_hidden_text: 'the country that you studied in',
            }
        end
      end
    end

    def country_value
      if application_qualification.institution_country
        COUNTRIES_AND_TERRITORIES[application_qualification.institution_country]
      else
        govuk_link_to('Enter the country or territory where you studied for your English qualification', candidate_interface_gcse_details_edit_institution_country_path(change_path_params))
      end
    end

    def enic_statement_row
      return nil unless application_qualification.qualification_type == 'non_uk'

      {
        key: t('application_form.gcse.enic_statement.review_label'),
        value: enic_value,
      }.tap do |row|
        if application_qualification.enic_reference?
          row[:action] =
            {
              href: candidate_interface_gcse_details_edit_enic_path(change_path_params),
              visually_hidden_text: t('application_form.gcse.enic_statement.change_action'),
            }
        end
      end
    end

    def enic_value
      if application_qualification.enic_reference?
        translate_enic_reason(application_qualification.enic_reason)
      else
        govuk_link_to('Enter your ENIC status', candidate_interface_gcse_details_edit_enic_path(change_path_params))
      end
    end

    def enic_reference_row
      return nil unless application_qualification.qualification_type == 'non_uk' &&
                        application_qualification.enic_reference

      {
        key: t('application_form.gcse.enic_reference.review_label'),
        value: application_qualification.enic_reference,
        action: {
          href: x_gcse_edit_statement_comparability_path(change_path_params[:subject]),
          visually_hidden_text: t('application_form.gcse.enic_reference.change_action'),
        },
        html_attributes: {
          data: {
            qa: 'gcse-enic-reference',
          },
        },
      }
    end

    def comparable_uk_qualification_row
      return nil unless application_qualification.qualification_type == 'non_uk' &&
                        application_qualification.enic_reference

      {
        key: t('application_form.gcse.comparable_uk_qualification.review_label'),
        value: application_qualification.comparable_uk_qualification,
        action: {
          href: x_gcse_edit_statement_comparability_path(change_path_params[:subject]),
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

    def grade_edit_path
      case subject
      when 'maths'
        candidate_interface_edit_gcse_maths_grade_path(return_to_params)
      when 'science'
        candidate_interface_edit_gcse_science_grade_path(return_to_params)
      when 'english'
        candidate_interface_edit_gcse_english_grade_path(return_to_params)
      end
    end

    def capitalize_english(subject)
      subject == 'english' ? 'English' : subject
    end
  end
end
