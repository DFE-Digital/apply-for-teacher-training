require 'rails_helper'

RSpec.describe ContactDetailsComponent do
  it 'renders component with correct structure' do
    contact_details_form = instance_double(
      'CandidateInterface::ContactDetailsForm',
      phone_number: '07700 900 982',
    )

    result = render_inline(ContactDetailsComponent, contact_details_form: contact_details_form)

    expect(result.css('.govuk-summary-list__key').text).to include(t('application_form.contact_details.phone_number.label'))
    expect(result.css('.govuk-summary-list__value').text).to include('07700 900 982')
    expect(result.css('.govuk-summary-list__actions a').attr('href').value).to include(Rails.application.routes.url_helpers.candidate_interface_contact_details_edit_path)
    expect(result.css('.govuk-summary-list__actions').text).to include("Change #{t('application_form.contact_details.phone_number.change_action')}")
  end
end
