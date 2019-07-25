require 'rails_helper'

describe 'A candidate entering contact details' do
  include TestHelpers::PersonalDetails

  context 'when details are correct' do
    before do
      visit '/contact_details/new'

      fill_in_contact_details
      click_on t('application_form.save_and_continue')
    end

    describe 'check_your_answers page' do
      it 'contains phone number' do
        expect(page).to have_content('Phone number')
        expect(page).to have_content('Email address')
        expect(page).to have_content('Postal address')
      end
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        visit '/check_your_answers'

        find('#change-phone_number').click
        expect(page).to have_field('Phone number', with: '1234567890')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/contact_details/new'
      click_on t('application_form.save_and_continue')
    end

    it 'sees an error summary with clickable links', js: true do
      expect(page).to have_content('There is a problem')
      click_on 'Enter your phone number'
      expect(page).to have_selector('#contact_details_phone_number:focus')
    end
  end

private

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
