require 'rails_helper'

describe 'A candidate adding a Degree' do
  include TestHelpers::DegreeDetails

  context 'who successfully enters their details' do
    before do
      visit '/degrees/new'

      fill_in_degree_details

      click_on t('application_form.save_and_continue')
    end

    it 'sees a summary of those details' do
      expect(page).to have_content('BA')
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        visit '/check_your_answers'

        find('#change-degree').click
        expect(page).to have_field('Type of degree', with: 'BA')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      visit '/degrees/new'
    end

    it 'sees an error summary' do
      click_on t('application_form.save_and_continue')

      expect(page).to have_content('There is a problem')
    end
  end
end
