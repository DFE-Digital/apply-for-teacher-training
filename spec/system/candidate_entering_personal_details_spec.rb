require 'rails_helper'

describe 'A candidate entering personal details' do
  include TestHelpers::PersonalDetails

  context 'who successfully enters their details' do
    before do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)

      visit '/personal-details/new'

      fill_in_personal_details

      click_on t('application_form.save_and_continue')
    end

    it 'sees a summary of those details' do
      visit '/check-your-answers'

      expect(page).to have_content('First name John')
    end

    context 'and wishes to amend their details' do
      it 'can go back and edit them' do
        visit '/check-your-answers'

        find('#change-first_name').click
        expect(page).to have_field('First name', with: 'John')
      end
    end
  end

  context 'who leaves out a required field' do
    before do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate, scope: :candidate)

      visit '/personal-details/new'

      click_on t('application_form.save_and_continue')
    end

    it 'sees an error summary with clickable links' do
      expect(page).to have_content('There is a problem')
    end
  end
end
