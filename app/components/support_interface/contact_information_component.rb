module SupportInterface
  class ContactInformationComponent < ViewComponent::Base
    MISSING = '<em>Not provided</em>'.html_safe

    delegate :phone_number,
             :candidate,
             to: :application_form

    delegate :email_address, to: :candidate

    def initialize(application_form:)
      @application_form = application_form
    end

    def rows
      [
        phone_number_row,
        email_row,
        address_row,
      ].compact
    end

  private

    def email_row
      row = {
        key: 'Email address',
        value: govuk_mail_to(email_address, email_address),
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_applicant_details_path(application_form),
          visually_hidden_text: 'email address',
        },
      )
    end

    def phone_number_row
      row = {
        key: 'Phone number',
        value: phone_number || MISSING,
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_applicant_details_path(application_form),
          visually_hidden_text: 'phone number',
        },
      )
    end

    def address_row
      row = {
        key: 'Address',
        value: full_address,
      }
      return row unless editable?

      row.merge(
        action: {
          href: support_interface_application_form_edit_address_type_path(application_form),
          visually_hidden_text: 'address',
        },
      )
    end

    def full_address
      if @application_form.address_type == 'uk'
        local_address.compact_blank
      else
        local_address.push(CountryFinder.find_name_from_hesa_code(@application_form.country)).compact_blank
      end
    end

    def local_address
      [
        @application_form.address_line1,
        @application_form.address_line2,
        @application_form.address_line3,
        @application_form.address_line4,
        @application_form.postcode,
      ]
    end

    attr_reader :application_form

    def editable?
      application_form.editable?
    end
  end
end
