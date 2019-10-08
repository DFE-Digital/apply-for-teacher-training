require 'rails_helper'

# TODO: This test needs to be rewritten to use the new acceptance-test style
# specs - https://github.com/DFE-Digital/apply-for-postgraduate-teacher-training/pull/246
describe 'A candidate signing up' do
  include TestHelpers::SignUp

  context 'who does not have an account' do
    before do
      visit '/'
      click_on t('application_form.begin_button')
      fill_in_sign_up
    end

    it 'sees the check your email page' do
      expect(page).to have_content t('authentication.check_your_email')
    end

    it 'receives the sign up email' do
      open_email('april@pawnee.com')

      expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
    end

    context 'receives an email with a valid magic link' do
      let(:sign_in_link) { current_email.find_css('a').first }

      before do
        open_email('april@pawnee.com')
      end

      it 'does sign the user in' do
        sign_in_link.click
        expect(page).to have_content 'april@pawnee.com'
      end

      it 'does not sign the user in when the token expiration time has passed' do
        Timecop.travel(Time.now + 1.hour + 1.second) do
          sign_in_link.click

          expect(page).not_to have_content 'april@pawnee.com'
        end
      end
    end
  end

  context 'who already has an account' do
    before do
      visit candidate_interface_sign_up_path
      fill_in_sign_up
      open_email('april@pawnee.com')
      current_email.find_css('a').first.click
      click_link 'Sign out'

      visit candidate_interface_sign_up_path
      fill_in_sign_up
    end

    it 'receives the sign in email' do
      open_email('april@pawnee.com')

      expect(current_email.subject).to have_content t('authentication.sign_in.email.subject')
    end

    it 'sees the check your email page' do
      expect(page).to have_content t('authentication.check_your_email')
    end

    it 'does sign the user in' do
      open_email('april@pawnee.com')
      current_email.find_css('a').first.click

      expect(page).to have_content 'april@pawnee.com'
    end
  end

  context 'who clicks a link with an invalid token' do
    it 'sees the start page' do
      visit candidate_interface_application_form_path(token: 'meow')

      expect(page).to have_current_path(candidate_interface_start_path)
    end
  end

  it 'takes the user back to the start page' do
    visit candidate_interface_sign_up_path

    click_link 'Back'

    expect(page).to have_current_path(candidate_interface_start_path)
  end
end
