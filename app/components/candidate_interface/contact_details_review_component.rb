module CandidateInterface
  class ContactDetailsReviewComponent < ViewComponent::Base
    def initialize(application_form:, editable: true, missing_error: false, submitting_application: false, return_to_application_review: false)
      @application_form = application_form
      @contact_details_form = CandidateInterface::ContactDetailsForm.build_from_application(
        @application_form,
      )
      @editable = editable
      @missing_error = missing_error
      @submitting_application = submitting_application
      @return_to_application_review = return_to_application_review
    end

    def contact_details_form_rows
      [phone_number_row, address_row].compact
    end

    def show_missing_banner?
      !@application_form.contact_details_completed && @editable if @submitting_application
    end

  private

    attr_reader :application_form

    def phone_number_row
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
    end

    def address_row
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
    end

    def full_address
      if @contact_details_form.uk?
        local_address.reject(&:blank?)
      else
        local_address.concat([COUNTRIES_AND_TERRITORIES[@contact_details_form.country]]).reject(&:blank?)
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

    def return_to_params
      { 'return-to' => 'application-review' } if @return_to_application_review
    end
  end
end
