require 'rails_helper'

describe 'A candidate signing in' do
  include TestHelpers::SignUp

  before do
    visit '/'
    click_on 'sign in'

    fill_in t('authentication.sign_in.email_address.label'), with: 'new_candidate@example.com'
  end

  it 'sees the sign in page' do
    expect(page).to have_content 'Enter the email address you used to register with'
  end

  context 'when the email does not exist' do
    it 'sees the "Check your email" page' do
      fill_in t('authentication.sign_in.email_address.label'), with: 'non_existent_candidate@example.com'
      click_on t('authentication.sign_up.button')

      expect(page).to have_content 'Check your email'
      expect(page.current_url).to eq(candidate_interface_sign_in_url)
    end
  end

  context 'who successfully signs in' do
    it 'sees the "Check your email" page' do
      fill_in t('authentication.sign_in.email_address.label'), with: 'candidate@example.com'
      click_on t('authentication.sign_up.button')

      expect(page).to have_content 'Check your email'
      expect(page.current_url).to eq(candidate_interface_sign_in_url)
    end

    it 'receives the email' do
      visit '/candidate/sign-up'
      fill_in_sign_up

      visit '/candidate/sign-in'
      fill_in t('authentication.sign_in.email_address.label'), with: 'april@pawnee.com'
      click_on 'Continue'

      open_email('april@pawnee.com')

      sign_in_link = current_email.find_css('a').first
      sign_in_link.click

      # TODO: this will be changed to the application page of candidate
      expect(page).to have_content('Welcome')
    end
  end
end
