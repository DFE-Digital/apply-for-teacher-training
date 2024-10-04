require 'rails_helper'

RSpec.describe 'Candidate sign in is blocked' do
  scenario 'I do not see the sign in form' do
    given_candidate_sign_in_is_blocked
    when_i_visit_the_sign_in_page
    then_i_see_the_unavailable_message
    and_i_do_not_see_the_sign_in_form
  end

  scenario 'I do not see the create an account or sign in page form' do
    given_candidate_sign_in_is_blocked
    when_i_visit_the_create_account_or_sign_in_page
    then_i_see_the_unavailable_message
    and_i_do_not_see_the_sign_in_or_create_an_account_form
  end

  scenario 'I do not see the sign up page form' do
    given_candidate_sign_in_is_blocked
    when_i_visit_the_sign_up_page
    then_i_see_the_unavailable_message
    and_i_do_not_see_the_sign_up_form
  end

private

  def given_candidate_sign_in_is_blocked
    FeatureFlag.activate(:block_candidate_sign_in)
  end

  def when_i_visit_the_sign_in_page
    visit candidate_interface_sign_up_path
  end

  def when_i_visit_the_create_account_or_sign_in_page
    visit candidate_interface_account_path
  end

  def when_i_visit_the_sign_up_page
    visit candidate_interface_sign_up_path
  end

  def and_i_do_not_see_the_sign_in_form
    expect(page).to have_no_content 'Email address'
  end

  def then_i_see_the_unavailable_message
    expect(page).to have_content 'Sign in temporarily unavailable'
  end

  def and_i_do_not_see_the_sign_in_or_create_an_account_form
    expect(page).to have_no_content 'Email address'
  end

  def and_i_do_not_see_the_sign_up_form
    expect(page).to have_no_content 'Email address'
  end
end
