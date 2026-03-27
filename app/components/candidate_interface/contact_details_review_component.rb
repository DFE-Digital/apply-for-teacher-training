module CandidateInterface
  class ContactDetailsReviewComponent < ApplicationComponent
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: true)
      @application_form = application_form
      @contact_details_form = CandidateInterface::ContactDetailsForm.build_from_application(
        @application_form,
      )
      @residency_form = CandidateInterface::ResidencyForm.build_from_application(
        @application_form,
      )
      @residency_date_form = CandidateInterface::ResidencyDateForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def contact_details_form_rows
      [phone_number_row, address_row, residency_row, residency_date_row].compact
    end

    def show_missing_banner?
      !@application_form.contact_details_completed && @editable if @submitting_application
    end

    def show_invalid_banner?
      return false unless @editable && @submitting_application

      if FeatureFlag.active?('2027_application_form_contact_details_residency_questions')
        !(
          @contact_details_form.valid_for_submission? ||
          @residency_form.valid? ||
          @residency_date_form.valid?
        )
      else
        !@contact_details_form.valid_for_submission?
      end
    end

  private

    attr_reader :application_form

    def phone_number_row
      if @contact_details_form.phone_number.present?
        {
          key: t('application_form.contact_details.phone_number.label'),
          value: @contact_details_form.phone_number,
          action: {
            href: candidate_interface_edit_phone_number_path(return_to_params),
            visually_hidden_text: t('application_form.contact_details.phone_number.change_action'),
          },
          html_attributes: {
            data: {
              qa: 'contact-details-phone-number',
            },
          },
        }
      else
        {
          key: t('application_form.contact_details.phone_number.label'),
          value: govuk_link_to(
            'Enter phone number',
            candidate_interface_edit_phone_number_path(return_to_params),
          ),
          html_attributes: {
            data: {
              qa: 'contact-details-phone-number',
            },
          },
        }
      end
    end

    def address_row
      if address_complete?
        {
          key: t('application_form.contact_details.full_address.label'),
          value: full_address,
          action: {
            href: candidate_interface_edit_address_type_path(return_to_params),
            visually_hidden_text: t('application_form.contact_details.full_address.change_action'),
          },
          html_attributes: {
            data: {
              qa: 'contact-details-address',
            },
          },
        }
      elsif address_only_missing_postcode?
        {
          key: t('application_form.contact_details.full_address.label'),
          value: full_address +
            [govuk_link_to(
              'Enter postcode',
              candidate_interface_edit_address_path(return_to_params),
            )],
          action: {
            href: candidate_interface_edit_address_type_path(return_to_params),
            visually_hidden_text: t('application_form.contact_details.full_address.change_action'),
          },
          html_attributes: {
            data: {
              qa: 'contact-details-address',
            },
          },
        }
      else
        {
          key: t('application_form.contact_details.full_address.label'),
          value: govuk_link_to(
            'Enter address',
            candidate_interface_edit_address_type_path(return_to_params),
          ),
          html_attributes: {
            data: {
              qa: 'contact-details-address',
            },
          },
        }
      end
    end

    def residency_row
      return unless FeatureFlag.active?('2027_application_form_contact_details_residency_questions')

      if @residency_form.since_birth.present?
        {
          key: t('application_form.contact_details.residency.label', country: @application_form.country_of_residence),
          value: @residency_form.since_birth.capitalize,
          action: {
            href: candidate_interface_edit_residency_path(return_to_params),
            visually_hidden_text: t('application_form.contact_details.residency.change_action'),
          },
          html_attributes: {
            data: {
              qa: 'contact-details-residency',
            },
          },
        }
      else
        {
          key: t('application_form.contact_details.residency.label', country: @application_form.country_of_residence),
          value: govuk_link_to(
            'Enter residency information',
            candidate_interface_edit_residency_path(return_to_params),
          ),
          html_attributes: {
            data: {
              qa: 'contact-details-residency',
            },
          },
        }
      end
    end

    def residency_date_row
      return unless FeatureFlag.active?('2027_application_form_contact_details_residency_questions')
      return unless @application_form.country_residency_since_birth == false

      if @residency_date_form.date.is_a?(Date)
        {
          key: t('application_form.contact_details.residency_date.label', country: @application_form.country_of_residence),
          value: @residency_date_form.date.to_fs(:month_and_year),
          action: {
            href: candidate_interface_edit_residency_date_path(return_to_params),
            visually_hidden_text: t('application_form.contact_details.residency_date.change_action'),
          },
          html_attributes: {
            data: {
              qa: 'contact-details-residency-date',
            },
          },
        }
      else
        {
          key: t('application_form.contact_details.residency_date.label', country: @application_form.country_of_residence),
          value: govuk_link_to(
            "Enter from what date you have lived in #{@application_form.country_of_residence}",
            candidate_interface_edit_residency_date_path(return_to_params),
          ),
          html_attributes: {
            data: {
              qa: 'contact-details-residency-date',
            },
          },
        }
      end
    end

    def full_address
      if @contact_details_form.uk?
        local_address.compact_blank
      else
        local_address.push(CountryFinder.find_name_from_hesa_code(@contact_details_form.country)).compact_blank
      end
    end

    def local_address
      [
        @contact_details_form.address_line1,
        @contact_details_form.address_line2,
        @contact_details_form.address_line3,
        @contact_details_form.address_line4,
        @contact_details_form.postcode,
      ]
    end

    def address_complete?
      @contact_details_form.valid?(:address_type) && @contact_details_form.valid?(:address)
    end

    def address_only_missing_postcode?
      @contact_details_form.validate(:address)
      @contact_details_form.errors.attribute_names == %i[postcode]
    end

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
