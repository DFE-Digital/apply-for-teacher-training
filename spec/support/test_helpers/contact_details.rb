module TestHelpers
  module ContactDetails
    def fill_in_contact_details
      details = {
        phone_number: '1234567890',
        email_address: 'john.doe@example.com',
        address: 'Westminster, London SW1P 1QW'
      }

      fill_in t('application_form.contact_details_section.phone_number.label'), with: details[:phone_number]
      fill_in t('application_form.contact_details_section.email_address.label'), with: details[:email_address]
      fill_in t('application_form.contact_details_section.address.label'), with: details[:address]
    end
  end
end
