module SupportInterface
  class PersonalInformationComponent < ViewComponent::Base
    include CandidateDetailsHelper

    MISSING = '<em>Not provided</em>'.html_safe
    RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES = {
      'yes' => 'Yes',
      'no' => 'No',
      'decide_later' => 'No',
    }.freeze

    include ViewHelper

    delegate :first_name,
             :last_name,
             :candidate,
             to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        first_name_row,
        last_name_row,
        date_of_birth_row,
        nationality_row,
        domicile_row,
        right_to_work_or_study_row,
        residency_details_row,
      ].compact
    end

  private

    def first_name_row
      row = {
        key: 'First name',
        value: first_name,
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_applicant_details_path(application_form),
          visually_hidden_text: 'first name',
        },
      )
    end

    def last_name_row
      row = {
        key: 'Last name',
        value: last_name,
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_applicant_details_path(application_form),
          visually_hidden_text: 'last name',
        },
      )
    end

    def nationality_row
      row = {
        key: 'Nationality',
        value: application_form.nationalities.to_sentence(last_word_connector: ' and '),
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_nationalities_path(application_form),
          visually_hidden_text: 'nationality',
        },
      )
    end

    def domicile_row
      {
        key: 'Domicile',
        value: application_form.domicile,
      }
    end

    def right_to_work_or_study_row
      return if application_form.right_to_work_or_study.blank?

      row = {
        key: 'Has the right to work or study in the UK?',
        value: RIGHT_TO_WORK_OR_STUDY_DISPLAY_VALUES.fetch(application_form.right_to_work_or_study),
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_immigration_right_to_work_path(application_form),
          visually_hidden_text: 'right to work or study',
        },
      )
    end

    def residency_details_row
      return unless application_form.right_to_work_or_study == 'yes'

      row = {
        key: I18n.t('support_interface.edit_immigration_status.visa_or_immigration_status_text'),
        value: FormatResidencyDetailsService.new(application_form:).residency_details_value,
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_immigration_status_path(application_form),
          visually_hidden_text: I18n.t('support_interface.edit_immigration_status.visa_or_immigration_status_text').downcase,
        },
      )
    end

    def date_of_birth_row
      row = {
        key: 'Date of birth',
        value: application_form.date_of_birth ? application_form.date_of_birth.to_fs(:govuk_date) : MISSING,
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_applicant_details_path(application_form),
          visually_hidden_text: 'date of birth',
        },
      )
    end

    attr_reader :application_form

    def editable?
      application_form.editable?
    end
  end
end
