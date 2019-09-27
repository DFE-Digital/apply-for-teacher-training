require 'rails_helper'

describe 'A candidate signing out' do
  context 'when a candidate is signed in' do
    before do
      candidate = FactoryBot.create(:candidate)
      login_as(candidate)

      visit candidate_interface_welcome_path
    end

    it 'displays a sign out button' do
      expect(page).to have_selector :link_or_button, 'Sign out'
    end

    describe 'click the sign out button' do
      it 'displays the start page' do
        click_link 'Sign out'

        expect(page).to have_current_path(candidate_interface_start_path)
      end

      it 'can only access start page' do
        click_link 'Sign out'

        visit candidate_interface_welcome_path

        expect(page).to have_current_path(candidate_interface_start_path)
      end
    end
  end

  context 'when a candidate is not signed in' do
    it 'does not display a sign out button' do
      visit candidate_interface_start_path

      expect(page).not_to have_selector :link_or_button, 'Sign out'
    end
  end
end
