module CandidateInterface
  class OtherQualificationsReviewComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:, editable: true, heading_level: 2, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @qualifications =
        CandidateInterface::OtherQualificationDetailsForm.build_all(@application_form)
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
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

    def no_qualification_row
      params = { change: true }.merge(return_to_params)
      [{
        key: 'Do you want to add any A levels and other qualifications',
        value: 'No',
        change_path: candidate_interface_other_qualification_type_path(params),
      }]
    end

  private

    attr_reader :application_form

    def qualification_row(qualification)
      {
        key: t('application_form.other_qualification.qualification.label'),
        value: qualification_value(qualification),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.qualification.change_action')),
        change_path: edit_other_qualification_type_path(qualification),
        data_qa: 'other-qualifications-type',
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
        value: rows_value(qualification.subject),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.subject.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
        data_qa: 'other-qualifications-subject',
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
        data_qa: 'other-qualifications-country',
      }
    end

    def country_value(qualification)
      if non_uk_qualification?(qualification) && qualification.institution_country.present?
        COUNTRIES[qualification.institution_country].to_s
      else
        rows_value(qualification.institution_country)
      end
    end

    def non_uk_qualification?(qualification)
      qualification.non_uk_qualification_type.present?
    end

    def award_year_row(qualification)
      {
        key: t('application_form.other_qualification.award_year.review_label'),
        value: rows_value(qualification.award_year),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.award_year.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
        data_qa: 'other-qualifications-year-awarded',
      }
    end

    def grade_row(qualification)
      {
        key: grade_set_key(qualification),
        value: rows_value(qualification.grade),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.grade.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
        data_qa: 'other-qualifications-grade',
      }
    end

    def grade_set_key(qualification)
      if qualification.qualification_type == 'non_uk' || (qualification.qualification_type == 'Other' && qualification.qualification_type_name != 'BTEC')
        t('application_form.other_qualification.grade.optional_label')
      else
        t('application_form.other_qualification.grade.label')
      end
    end

    def rows_value(value)
      value || 'Not entered'
    end

    def edit_other_qualification_details_path(qualification)
      candidate_interface_edit_other_qualification_details_path(qualification.id, return_to_params)
    end

    def edit_other_qualification_type_path(qualification)
      candidate_interface_edit_other_qualification_type_path(qualification.id, return_to_params)
    end

    def generate_action(qualification:, attribute: '')
      "#{attribute.presence} for #{qualification.qualification_type_name}, #{qualification.subject}, "\
        "#{qualification.award_year}"
    end

    def return_to_params
      if @return_to_application_review
        { 'return-to' => 'application-review' }
      else
        {}
      end
    end
  end
end
