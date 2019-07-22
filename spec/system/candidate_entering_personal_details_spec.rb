require 'rails_helper'

describe 'A candidate entering personal details' do
  include TestHelpers::PersonalDetails

  context 'who successfully enters their details' do
    before do
      visit '/'
      click_on t('application_form.begin_button')

      fill_in_personal_details

      click_on t('application_form.save_and_continue')
    end

    it 'sees a summary of those details' do
      visit '/check_your_answers'

      expect(page).to have_content('First name John')
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        visit '/check_your_answers'

        find('#change-first_name').click
        expect(page).to have_field('First name', with: 'John')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/'
      click_on t('application_form.begin_button')
      click_on t('application_form.save_and_continue')
    end

    it 'sees an error summary with clickable links', js: true do
      expect(page).to have_content('There is a problem')
      click_on 'Enter your first name'
      expect(page).to have_selector('#personal_details_first_name:focus')
    end
  end
end
