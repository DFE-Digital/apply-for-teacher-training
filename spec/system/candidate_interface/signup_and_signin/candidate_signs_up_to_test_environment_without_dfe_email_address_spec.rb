require 'rails_helper'

RSpec.describe 'Candidate cannot sign up to a test environment (e.g. qa) without a DfE email address' do
  include SignInHelper

  around do |example|
    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'qa' do
      example.run
    end
  end

  scenario 'Candidate tries to sign up' do
    given_i_am_a_candidate_without_an_account

    when_i_go_to_sign_up
    and_i_submit_my_email_address
    then_i_see_an_access_forbidden_page

    given_i_have_a_dfe_email_address
    when_i_go_back_to_sign_up_again
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_up
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def given_i_have_a_dfe_email_address
    @email = "#{SecureRandom.hex}@education.gov.uk"
  end

  def when_i_go_to_sign_up
    visit '/'

    choose 'No, I need to create an account'
    click_link_or_button t('continue')
  end

  def when_i_go_back_to_sign_up_again
    click_link_or_button 'Back'
  end

  def then_i_see_an_access_forbidden_page
    expect(page).to have_current_path(candidate_interface_external_sign_up_forbidden_path)
    expect(page).to have_content('Only DfE users can sign into this website')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_link_or_button t('continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end
end
