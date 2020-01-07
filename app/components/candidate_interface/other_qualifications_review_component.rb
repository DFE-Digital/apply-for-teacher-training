module CandidateInterface
  class OtherQualificationsReviewComponent < ActionView::Component::Base
    include AriaDescribedbyHelper

    SECTION = 'other-qualifications'.freeze

    validates :application_form, presence: true

    def initialize(application_form:, editable: true, heading_level: 2, missing_error: false)
      @application_form = application_form
      @qualifications = CandidateInterface::OtherQualificationForm.build_all_from_application(
        @application_form,
      )
      @editable = editable
      @heading_level = heading_level
      @missing_error = missing_error
    end

    def other_qualifications_rows(qualification)
      [
        qualification_row(qualification),
        institution_row(qualification),
        award_year_row(qualification),
        grade_row(qualification),
      ]
    end

  private

    attr_reader :application_form

    def qualification_row(qualification)
      {
        id: generate_id(section: SECTION, entry_id: qualification.id, attribute: 'qualification'),
        key: t('application_form.other_qualification.qualification.label'),
        value: qualification.title,
        action: t('application_form.other_qualification.qualification.change_action'),
        change_path: edit_other_qualification_path(qualification),
        aria_describedby: aria_describedby(qualification.id),
      }
    end

    def institution_row(qualification)
      {
        id: generate_id(section: SECTION, entry_id: qualification.id, attribute: 'institution'),
        key: t('application_form.other_qualification.institution.label'),
        value: qualification.institution_name,
        action: t('application_form.other_qualification.institution.change_action'),
        change_path: edit_other_qualification_path(qualification),
        aria_describedby: aria_describedby(qualification.id),
      }
    end

    def award_year_row(qualification)
      {
        id: generate_id(section: SECTION, entry_id: qualification.id, attribute: 'year'),
        key: t('application_form.other_qualification.award_year.review_label'),
        value: qualification.award_year,
        action: t('application_form.other_qualification.award_year.change_action'),
        change_path: edit_other_qualification_path(qualification),
        aria_describedby: aria_describedby(qualification.id),
      }
    end

    def grade_row(qualification)
      {
        key: t('application_form.other_qualification.grade.label'),
        value: qualification.grade,
        action: t('application_form.other_qualification.grade.change_action'),
        change_path: edit_other_qualification_path(qualification),
        aria_describedby: aria_describedby(qualification.id),
      }
    end

    def edit_other_qualification_path(qualification)
      Rails.application.routes.url_helpers.candidate_interface_edit_other_qualification_path(qualification.id)
    end

    def aria_describedby(qualification_id)
      generate_aria_describedby(
        section: SECTION,
        entry_id: qualification_id,
        attributes: %w[qualification institution year],
      )
    end
  end
end
