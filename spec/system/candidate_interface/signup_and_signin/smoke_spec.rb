require 'rails_helper'

RSpec.feature 'Smoke test', smoke_test: true, js: true do
  include SignInHelper

  # clear any outstandin smoketest candidates left over from a failed previous run
  before { ClearSmokeTestCandidates.call }

  # clear smoke testing candidate accounts just created
  after { ClearSmokeTestCandidates.call }

  it 'allows new account creation' do
    given_i_am_a_candidate_without_an_account

    when_i_visit_the_signup_page

    and_i_submit_my_email_address

    and_i_confirm_account_creation
    then_i_am_signed_in
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@smoketest.example.com"
  end

  def when_i_visit_the_signup_page
    visit candidate_interface_sign_up_path
  end

  def and_i_submit_my_email_address(email = @email)
    fill_in t('authentication.sign_up.email_address.label'), with: email
    click_on t('continue')
  end

  def and_i_confirm_account_creation
    confirm_create_account
  end

  def then_i_am_signed_in
    within 'header' do
      expect(page).to have_content @email
    end
  end
end
