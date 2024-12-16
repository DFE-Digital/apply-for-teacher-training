require 'rails_helper'

RSpec.describe 'Candidate signs in' do
  include OneLoginHelper

  scenario 'Candidate signs in and signs out' do
    given_i_have_a_candidate_record
    given_i_have_one_login_account(@candidate.email_address)
    given_the_one_login_feature_flag_is_active

    when_i_visit_the_candidate_application_path
    then_i_am_redirected_to_the_candidate_sign_in_path
    when_i_click_continue
    then_i_am_redirected_to_the_candidate_application_path

    when_i_click_sign_out
    i_am_redirected_back_to_sign_in_page

    when_i_visit_the_candidate_application_path
    then_i_am_redirected_to_the_candidate_sign_in_path
  end

  scenario 'Candidate signs in without a candidate account' do
    given_i_have_one_login_account('test@email.com')
    given_the_one_login_feature_flag_is_active

    when_i_visit_the_candidate_application_path
    then_i_am_redirected_to_the_candidate_sign_in_path
    when_i_click_continue
  end

  scenario 'Candidate already has a different one login attached to candidate record' do
    given_i_have_a_candidate_record
    given_i_already_have_a_different_one_login_token(@candidate)
    given_i_have_one_login_account(@candidate.email_address)
    given_the_one_login_feature_flag_is_active

    when_i_visit_the_candidate_application_path
    then_i_am_redirected_to_the_candidate_sign_in_path
    when_i_click_continue
    i_am_redirected_back_to_sign_in_page
  end

  def given_i_have_a_candidate_record
    @candidate = create(:candidate)
  end

  def given_i_have_one_login_account(email_address)
    user_exists_in_onelogin(email_address:)
  end

  def given_i_already_have_a_different_one_login_token(candidate)
    candidate.create_one_login_auth!(
      token: '123',
      email_address: candidate.email_address,
    )
  end

  def given_the_one_login_feature_flag_is_active
    FeatureFlag.activate(:one_login_candidate_sign_in)
  end

  def when_i_visit_the_candidate_application_path
    visit candidate_interface_details_path
  end

  def then_i_am_redirected_to_the_candidate_sign_in_path
    expect(page).to have_current_path(
      candidate_interface_create_account_or_sign_in_path,
    )
  end

  def when_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_am_redirected_to_the_candidate_application_path
    expect(page).to have_current_path(
      candidate_interface_details_path,
    )
  end

  def when_i_click_sign_out
    click_link_or_button 'Sign out'
  end

  def i_am_redirected_back_to_sign_in_page
    expect(page).to have_current_path(
      '/candidate/account',
    )
  end
end
