module CandidateInterface
  class GcseQualificationReviewComponent < ViewComponent::Base
    def initialize(application_form:, application_qualification:, subject:, editable: true, heading_level: 2, missing_error: false, submitting_application: false)
      @application_form = application_form
      @application_qualification = application_qualification
      @subject = subject
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def gcse_qualification_rows
      if application_qualification.missing_qualification?
        [missing_qualification_row]
      elsif FeatureFlag.active?('international_gcses') && @application_qualification.qualification_type == 'non_uk'
        [
          qualification_row,
          country_row,
          naric_row,
          comparable_uk_qualification,
          grade_row,
          award_year_row,
        ]
      else
        [
          qualification_row,
          grade_row,
          award_year_row,
        ]
      end
    end

    def show_missing_banner?
      if @submitting_application
        gcse_completed = "#{@subject}_gcse_completed"
        !@application_form.send(gcse_completed) && @editable
      end
    end

  private

    attr_reader :application_qualification, :subject

    def qualification_row
      {
        key: t('application_form.gcse.qualification.label'),
        value: gcse_qualification_types[application_qualification.qualification_type.to_sym.downcase],
        action: "qualification for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        change_path: candidate_interface_gcse_details_edit_type_path(subject: subject),
      }
    end

    def award_year_row
      {
        key: 'Year awarded',
        value: application_qualification.award_year || t('gcse_summary.not_specified'),
        action: "year awarded for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        change_path: candidate_interface_gcse_details_edit_year_path(subject: subject),
      }
    end

    def grade_row
      {
        key: 'Grade',
        value: application_qualification.grade ? application_qualification.grade.upcase : t('gcse_summary.not_specified'),
        action: "grade for #{gcse_qualification_types[application_qualification.qualification_type.to_sym]}, #{subject}",
        change_path: candidate_interface_gcse_details_edit_grade_path(subject: subject),
      }
    end

    def missing_qualification_row
      {
        key: 'How I expect to gain this qualification',
        value: application_qualification.missing_explanation.presence || t('gcse_summary.not_specified'),
        action: 'how do you expect to gain this qualification',
        change_path: candidate_interface_gcse_details_edit_type_path(subject: subject),
      }
    end

    def gcse_qualification_types
      t('application_form.gcse.qualification_types').merge(
        other_uk: application_qualification.other_uk_qualification_type,
        non_uk: application_qualification.non_uk_qualification_type,
      )
    end

    def country_row
      {
        key: 'Country',
        value: COUNTRIES[application_qualification.institution_country],
        action: 'Change the country that you studied in',
        change_path: candidate_interface_gcse_details_edit_institution_country_path(subject: subject),
      }
    end

    def naric_row
      {
        key: 'NARIC reference number',
        value: application_qualification.naric_reference || 'Not provided',
        action: 'Change the NARIC reference number',
        change_path: candidate_interface_gcse_details_edit_naric_reference_path(subject: subject),
      }
    end

    def comparable_uk_qualification
      {
        key: 'Comparable UK qualification',
        value: application_qualification.comparable_uk_qualification || 'Not provided',
        action: 'Change the comparable uk qualification',
        change_path: candidate_interface_gcse_details_edit_naric_reference_path(subject: subject),
      }
    end
  end
end
