require 'rails_helper'

describe 'A candidate completing an application for teacher training' do
  include TestHelpers::PersonalDetails
  include TestHelpers::ContactDetails
  include TestHelpers::DegreeDetails

  context 'who submits a valid application' do
    before do
      visit '/'
      click_on t('application_form.begin_button')

      fill_in_personal_details
      click_on t('application_form.save_and_continue')

      fill_in_contact_details
      click_on t('application_form.save_and_continue')

      fill_in_degree_details
      click_on t('application_form.save_and_continue')

      visit '/check_your_answers'
      click_on t('application_form.submit')
    end

    it 'can see that the application has been successfully submitted' do
      expect(page).to have_content 'bananas'
    end
  end
end
