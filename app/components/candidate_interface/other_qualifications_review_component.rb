module CandidateInterface
  class OtherQualificationsReviewComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:, editable: true, heading_level: 2, missing_error: false, submitting_application: false)
      @application_form = application_form
      @qualifications =
        CandidateInterface::OtherQualificationDetailsForm.build_all(@application_form)
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def other_qualifications_rows(qualification)
      if qualification.institution_country.present?
        [
          qualification_row(qualification),
          subject_row(qualification),
          country_row(qualification),
          award_year_row(qualification),
          grade_row(qualification),
        ]
      else
        [
          qualification_row(qualification),
          subject_row(qualification),
          award_year_row(qualification),
          grade_row(qualification),
        ]
      end
    end

    def show_missing_banner?
      @submitting_application && @application_form.application_qualifications.other.any?(&:incomplete_other_qualification?)
    end

  private

    attr_reader :application_form

    def qualification_row(qualification)
      {
        key: t('application_form.other_qualification.qualification.label'),
        value: qualification_value(qualification),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.qualification.change_action')),
        change_path: edit_other_qualification_type_path(qualification),
      }
    end

    def qualification_value(qualification)
      if qualification.non_uk_qualification_type.present?
        qualification.non_uk_qualification_type
      elsif qualification.other_uk_qualification_type.present?
        qualification.other_uk_qualification_type
      else
        qualification.qualification_type
      end
    end

    def subject_row(qualification)
      {
        key: subject_set_key(qualification),
        value: set_rows_value(qualification.subject),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.subject.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def subject_set_key(qualification)
      if qualification.qualification_type == 'non_uk'
        t('application_form.other_qualification.subject.optional_label')
      else
        t('application_form.other_qualification.subject.label')
      end
    end

    def country_row(qualification)
      {
        key: t('application_form.other_qualification.country.label'),
        value: country_value(qualification),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.country.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def country_value(qualification)
      if non_uk_qualification?(qualification) && qualification.institution_country.present?
        COUNTRIES[qualification.institution_country].to_s
      else
        set_rows_value(qualification.institution_country)
      end
    end

    def non_uk_qualification?(qualification)
      qualification.non_uk_qualification_type.present?
    end

    def award_year_row(qualification)
      {
        key: t('application_form.other_qualification.award_year.review_label'),
        value: set_rows_value(qualification.award_year),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.award_year.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def grade_row(qualification)
      {
        key: grade_set_key(qualification),
        value: set_rows_value(qualification.grade),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.grade.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def grade_set_key(qualification)
      if qualification.qualification_type == 'non_uk' || (qualification.qualification_type == 'Other' && qualification.qualification_type_name != 'BTEC')
        t('application_form.other_qualification.grade.optional_label')
      else
        t('application_form.other_qualification.grade.label')
      end
    end

    def set_rows_value(value)
      value || 'Not entered'
    end

    def edit_other_qualification_details_path(qualification)
      Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_details_path(qualification.id)
    end

    def edit_other_qualification_type_path(qualification)
      Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_type_path(qualification.id)
    end

    def generate_action(qualification:, attribute: '')
      "#{attribute.presence} for #{qualification.qualification_type_name}, #{qualification.subject}, "\
        "#{qualification.award_year}"
    end
  end
end
