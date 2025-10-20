module CandidateInterface
  class PersonalDetailsReviewPresenter
    include ActionView::Helpers::TagHelper
    include Rails.application.routes.url_helpers
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include ActionView::Helpers::UrlHelper

    def initialize(personal_details_form:, nationalities_form:, right_to_work_form:, application_form:, editable: true, return_to_application_review: false)
      @personal_details_form = personal_details_form
      @nationalities_form = nationalities_form
      @right_to_work_or_study_form = right_to_work_form
      @application_form = application_form
      @editable = editable
      @return_to_application_review = return_to_application_review
    end

    def rows
      assembled_rows = [
        name_row,
        date_of_birth_row,
        nationality_row,
      ]

      assembled_rows += right_to_work_rows || []
      assembled_rows.compact
    end

  private

    def name_row
      {
        key: I18n.t('application_form.personal_details.name.label'),
        value: @personal_details_form.name.presence || govuk_link_to('Enter your name', candidate_interface_edit_name_and_dob_path(return_to_params)),
        html_attributes: {
          data: {
            qa: 'personal-details-name',
          },
        },
      }.tap do |row|
        if @personal_details_form.name.present? && @editable
          row[:action] =
            {
              href: candidate_interface_edit_name_and_dob_path(return_to_params),
              visually_hidden_text: I18n.t('application_form.personal_details.name.change_action'),
            }
        end
      end
    end

    def date_of_birth_row
      {
        key: I18n.t('application_form.personal_details.date_of_birth.label'),
        value: date_of_birth_value,
        html_attributes: {
          data: {
            qa: 'personal-details-dob',
          },
        },
      }.tap do |row|
        row[:action] =
          (if @editable && @application_form.date_of_birth.is_a?(Date)
             {
               href: candidate_interface_edit_name_and_dob_path(return_to_params),
               visually_hidden_text: I18n.t('application_form.personal_details.date_of_birth.change_action'),
             }
           end)
      end
    end

    def date_of_birth_value
      if @personal_details_form.date_of_birth.is_a?(Date)
        @personal_details_form.date_of_birth.to_fs(:govuk_date)
      else
        govuk_link_to('Enter your date of birth', candidate_interface_edit_name_and_dob_path(return_to_params))
      end
    end

    def nationality_row
      {
        key: I18n.t('application_form.personal_details.nationality.label'),
        value: nationality_value,
        html_attributes: {
          data: {
            qa: 'personal-details-nationality',
          },
        },
      }.tap do |row|
        row[:action] =
          (if @editable && !@application_form.submitted_applications? && @application_form.first_nationality
             {
               href: candidate_interface_edit_nationalities_path(return_to_params),
               visually_hidden_text: I18n.t('application_form.personal_details.nationality.change_action'),
             }
           end)
      end
    end

    def nationality_value
      if @application_form.first_nationality
        formatted_nationalities
      else
        govuk_link_to('Enter your nationality', candidate_interface_edit_nationalities_path(return_to_params))
      end
    end

    def right_to_work_rows
      return nil if british_or_irish?

      rows = [
        {
          key: I18n.t('application_form.personal_details.immigration_right_to_work.label'),
          value: formatted_immigration_right_to_work,
          html_attributes: {
            data: {
              qa: 'personal_details_immigration_right_to_work',
            },
          },
        }.tap do |row|
          row[:action] =
            (if @editable && !@application_form.right_to_work_or_study.nil? && !@application_form.submitted_applications?
               {
                 href: candidate_interface_edit_immigration_right_to_work_path(return_to_params),
                 visually_hidden_text: I18n.t('application_form.personal_details.immigration_right_to_work.change_action'),
               }
             end)
        end,
      ]

      if @application_form.immigration_status
        rows << {
          key: I18n.t('application_form.personal_details.visa_or_immigration_status.label'),
          value: formatted_immigration_status,
          action: if @editable && !@application_form.submitted_applications?
                    {
                      href: candidate_interface_edit_immigration_status_path(return_to_params),
                      visually_hidden_text: I18n.t('application_form.personal_details.visa_or_immigration_status.change_action'),
                    }
                  end,
          html_attributes: { data: { qa: 'personal_details_visa_or_immigration_status' } },
        }
      end
      rows
    end

    def british_or_irish?
      @application_form.build_nationalities_hash[:irish] || @application_form.build_nationalities_hash[:british]
    end

    def formatted_nationalities
      [
        @nationalities_form.british,
        @nationalities_form.irish,
        @nationalities_form.other_nationality1,
        @nationalities_form.other_nationality2,
        @nationalities_form.other_nationality3,
      ]
      .compact_blank
      .to_sentence
    end

    def formatted_immigration_right_to_work
      return govuk_link_to('Select if you have the right to work or study in the UK', candidate_interface_personal_details_right_to_work_or_study_path(return_to_params)) if @application_form.right_to_work_or_study.nil?

      if immigration_right_to_work_form.right_to_work_or_study?
        'Yes'
      else
        'No'
      end
    end

    def formatted_immigration_status
      if @application_form.immigration_status == 'other'
        @application_form.right_to_work_or_study_details
      else
        I18n.t("application_form.personal_details.immigration_status.values.#{@application_form.immigration_status}")
      end
    end

    def formatted_right_to_work_or_study
      case @right_to_work_or_study_form.right_to_work_or_study
      when 'yes'
        "I have the right to work or study in the UK<br role='presentation'> #{tag.p(@right_to_work_or_study_form.right_to_work_or_study_details)}".html_safe
      when 'no'
        'I will need to apply for permission to work or study in the UK'
      else
        'I do not know'
      end
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end

    def immigration_right_to_work_form
      @immigration_right_to_work_form ||= CandidateInterface::ImmigrationRightToWorkForm.build_from_application(
        @application_form,
      )
    end
  end
end
