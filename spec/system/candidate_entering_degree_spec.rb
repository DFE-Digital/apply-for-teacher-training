require 'rails_helper'

describe 'A candidate adding a Degree' do
  include TestHelpers::DegreeDetails

  context 'who successfully enters their details' do
    before do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)

      visit '/degrees/new'

      fill_in_degree_details

      click_on t('application_form.save_and_continue')
    end

    it 'sees a summary of those details' do
      visit '/check-your-answers'

      expect(page).to have_content('BA')
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        visit '/check-your-answers'

        find('#change-degree').click

        expect(page).to have_content('Edit degree')
        expect(page).to have_field('Type of degree', with: 'BA')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)

      visit '/degrees/new'
    end

    it 'sees an error summary' do
      click_on t('application_form.save_and_continue')

      expect(page).to have_content('There is a problem')
    end
  end

  context 'who wants to add another degree' do
    before do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)
    end

    it 'navigates to the page Add degree' do
      visit '/check-your-answers'

      click_on t('application_form.degree_details_section.button.add_degree')

      expect(page).to have_content('Add degree')
    end
  end
end
