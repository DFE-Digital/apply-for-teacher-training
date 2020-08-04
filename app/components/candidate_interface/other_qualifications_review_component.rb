module CandidateInterface
  class OtherQualificationsReviewComponent < ViewComponent::Base
    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, missing_error: false, submitting_application: false)
      @application_form = application_form
      @qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(
        @application_form,
      )
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
      @submitting_application = submitting_application
    end

    def other_qualifications_rows(qualification)
      if FeatureFlag.active?('international_other_qualifications')
        [
          qualification_row(qualification),
          subject_row(qualification),
          institution_row(qualification),
          award_year_row(qualification),
          grade_row(qualification),
        ]
      else
        [
          qualification_row(qualification),
          institution_row(qualification),
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
      if FeatureFlag.active?('international_other_qualifications')
        {
          key: t('application_form.other_qualification.qualification.label'),
          value: qualification_value(qualification),
          action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.qualification.change_action')),
          change_path: edit_other_qualification_type_path(qualification),
        }
      else
        {
          key: t('application_form.other_qualification.qualification.label'),
          value: qualification_value(qualification),
          action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.qualification.change_action')),
          change_path: edit_other_qualification_details_path(qualification),
        }
      end
    end

    def qualification_value(qualification)
      if FeatureFlag.active?('international_other_qualifications')
        if qualification.non_uk_qualification_type.present?
          qualification.non_uk_qualification_type
        elsif qualification.other_uk_qualification_type.present?
          qualification.other_uk_qualification_type
        else
          qualification.qualification_type
        end
      else
        qualification.title
      end
    end

    def subject_row(qualification)
      {
        key: t('application_form.other_qualification.subject.label'),
        value: qualification.subject,
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.subject.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def institution_row(qualification)
      {
        key: t('application_form.other_qualification.institution.label'),
        value: institution_value(qualification),
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.institution.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def institution_value(qualification)
      if non_uk_qualification?(qualification) && qualification.institution_country.present?
        "#{qualification.institution_name}, #{qualification.institution_country}"
      else
        qualification.institution_name
      end
    end

    def non_uk_qualification?(qualification)
      FeatureFlag.active?('international_other_qualifications') && qualification.non_uk_qualification_type.present?
    end

    def award_year_row(qualification)
      {
        key: t('application_form.other_qualification.award_year.review_label'),
        value: qualification.award_year,
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.award_year.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def grade_row(qualification)
      {
        key: t('application_form.other_qualification.grade.label'),
        value: qualification.grade,
        action: generate_action(qualification: qualification, attribute: t('application_form.other_qualification.grade.change_action')),
        change_path: edit_other_qualification_details_path(qualification),
      }
    end

    def edit_other_qualification_details_path(qualification)
      Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_details_path(qualification.id)
    end

    def edit_other_qualification_type_path(qualification)
      Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_type_path(qualification.id)
    end

    def generate_action(qualification:, attribute: '')
      "#{attribute.presence} for #{qualification.get_qualification_type}, #{qualification.subject}, "\
        "#{institution_value(qualification)}, #{qualification.award_year}"
    end
  end
end
