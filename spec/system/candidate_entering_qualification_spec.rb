require 'rails_helper'

describe 'A candidate adding a qualification' do
  include TestHelpers::NonDegreeQualifications

  context 'who successfully enters their details' do
    before do
      visit '/qualifications/new'

      fill_in_qualification_details

      click_on t('application_form.save_and_continue')
    end

    it 'sees a summary of those details' do
      visit '/check-your-answers'

      expect(page).to have_content('GCSE')
    end

    it 'goes back and edit them' do
      visit '/check-your-answers'

      find('#change-qualification').click
      expect(page).to have_content('Edit qualification')

      expect(page).to have_field('Type of qualification', with: 'GCSE')
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/qualifications/new'
    end

    it 'sees an error summary' do
      click_on t('application_form.save_and_continue')

      expect(page).to have_content('There is a problem')
    end
  end

  context 'who wants to add another qualification' do
    it 'navigates to the "Add qualification" page' do
      visit '/check-your-answers'

      click_on t('application_form.qualification_section.button.add_another')

      expect(page).to have_content('Add qualification')
    end
  end
end
