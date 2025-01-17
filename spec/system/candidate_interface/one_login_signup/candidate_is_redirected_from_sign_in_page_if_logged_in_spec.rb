require 'rails_helper'

RSpec.describe 'Candidate is redirected from sign in page if already logged in' do
  include OneLoginHelper
  include CandidateHelper

  scenario 'User is signed in using OneLogin' do
    given_i_am_signed_in_with_one_login
    and_i_visit_the_candidate_account_page
    then_i_am_redirected_back_to_account_details
  end

  scenario 'User is signed in with magic link' do
    given_i_am_signed_in_with_magic_link
    and_i_visit_the_candidate_account_page
    then_i_am_redirected_back_to_account_details
  end

private

  def given_i_am_signed_in_with_magic_link
    FeatureFlag.deactivate(:one_login_candidate_sign_in)
    create_and_sign_in_candidate
    visit root_path
  end

  def and_i_visit_the_candidate_account_page
    click_on 'GOV.UK'
  end

  def then_i_am_redirected_back_to_account_details
    expect(page).to have_current_path(candidate_interface_details_path)
  end
end
