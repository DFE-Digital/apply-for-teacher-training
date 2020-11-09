require 'rails_helper'

RSpec.feature 'Candidate cannot sign up to a test environment (e.g. qa) without a DfE email address' do
  include SignInHelper

  around do |example|
    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'qa' do
      example.run
    end
  end

  scenario 'Candidate tries to sign up' do
    given_the_pilot_is_open
    and_the_international_personal_details_feature_is_active
    and_i_am_a_candidate_without_an_account

    when_i_go_to_sign_up
    and_i_submit_my_email_address
    then_i_see_an_error_message

    given_i_have_a_dfe_email_address
    when_i_go_to_sign_up
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_up
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_international_personal_details_feature_is_active
    FeatureFlag.activate('international_personal_details')
  end

  def and_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def given_i_have_a_dfe_email_address
    @email = "#{SecureRandom.hex}@education.gov.uk"
  end

  def when_i_go_to_sign_up
    visit '/'

    choose 'No, I need to create an account'
    click_button 'Continue'
  end

  def then_i_see_an_error_message
    expect(page).to have_current_path(candidate_interface_sign_up_path)
    expect(page).to have_content('Only DfE users can sign up in this test environment')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    check t('authentication.sign_up.accept_terms_checkbox')
    click_on t('authentication.sign_up.button_continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end
end
