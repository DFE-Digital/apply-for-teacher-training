require 'rails_helper'

describe 'A candidate completing an application for teacher training' do
  include TestHelpers::PersonalDetails
  include TestHelpers::ContactDetails
  include TestHelpers::DegreeDetails
  include TestHelpers::NonDegreeQualifications

  context 'when all the forms are correctly filled in' do
    let!(:notify_request) do
      stub_request(:post, /api.notifications.service.gov.uk/)
        .to_return(status: 200, body: '{}', headers: {})
    end

    before do
      visit '/'
      click_on t('application_form.begin_button')

      fill_in_personal_details
      click_on t('application_form.save_and_continue')

      fill_in_contact_details
      click_on t('application_form.save_and_continue')

      fill_in_degree_details
      click_on t('application_form.save_and_continue')

      fill_in_qualification_details
      click_on t('application_form.save_and_continue')
    end

    it 'can see the success page' do
      click_on t('application_form.submit')

      expect(page).to have_content t('application_form.application_submitted')
    end

    it 'has submitted their application' do
      click_on t('application_form.submit')

      expect(notify_request).to have_been_made
    end
  end
end
