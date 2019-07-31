require 'rails_helper'

describe 'A candidate entering contact details' do
  include TestHelpers::ContactDetails

  context 'when details are correct' do
    before do
      visit '/contact-details/new'

      fill_in_contact_details
      click_on t('application_form.save_and_continue')
    end

    describe 'visiting the check_your_answers page' do
      before do
        visit '/check-your-answers'
      end

      it 'sees a summary of those details' do
        expect(page).to have_content('Phone number 1234567890')
      end

      it 'can go back and edit them' do
        visit '/check-your-answers'

        find('#change-phone_number').click
        expect(page).to have_field('Phone number', with: '1234567890')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/contact-details/new'
      click_on t('application_form.save_and_continue')
    end

    it 'sees an error summary with clickable links', js: true do
      expect(page).to have_content('There is a problem')
      click_on 'Enter your phone number'
      expect(page).to have_selector('#contact_details_phone_number:focus')
    end
  end
end
