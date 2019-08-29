require 'rails_helper'

describe 'A candidate completing an application for teacher training' do
  include TestHelpers::PersonalDetails
  include TestHelpers::ContactDetails
  include TestHelpers::DegreeDetails
  include TestHelpers::NonDegreeQualifications

  context 'when all the forms are correctly filled in' do
    before do
      visit '/'
      click_on t('application_form.begin_button')

      fill_in t('authentication.sign_up.email_address.label'), with: 'april@pawnee.com'
      click_on t('authentication.sign_up.button')

      open_email('april@pawnee.com')
      current_email.find_css('a').first.click

      fill_in_personal_details
      click_on t('application_form.save_and_continue')

      fill_in_contact_details
      click_on t('application_form.save_and_continue')

      fill_in_degree_details
      click_on t('application_form.save_and_continue')

      fill_in_qualification_details
      click_on t('application_form.save_and_continue')
    end

    it 'can show the application submitted page' do
      click_on t('application_form.submit')

      expect(page).to have_content t('application_form.application_submitted')
    end

    it 'can successfully send application submission email' do
      ClimateControl.modify DEFAULT_PROVIDER_EMAIL: 'test@example.com' do
        click_on t('application_form.submit')
        open_email('test@example.com')

        expect(current_email.subject).to eq('Application submitted')
      end
    end
  end
end
