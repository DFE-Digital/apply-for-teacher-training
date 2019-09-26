require 'rails_helper'

describe 'A candidate signing in' do
  before do
    visit '/'
    click_on 'sign in'

    fill_in t('authentication.sign_in.email_address.label'), with: 'new_candidate@example.com'
  end

  it 'sees the the sign in page' do
    expect(page).to have_content 'Enter the email address you used to register with'
  end

  context 'who successfully signs in' do
    it 'sees the "Check your email" page' do
      fill_in t('authentication.sign_in.email_address.label'), with: 'new_candidate@example.com'
      click_on t('authentication.sign_up.button')

      expect(page).to have_content 'Check your email'
    end
  end
end
