require 'rails_helper'

RSpec.describe 'Candidate clicks unsubscribe link' do
  include CandidateHelper

  scenario 'Candidate is logged in and clicks on valid link' do
    given_i_am_signed_in
    and_i_visit_the_unsubscribe_link_with_valid_token
    then_i_am_unsubscribed
    and_i_see_unsubscribe_confirmation
  end

  scenario 'Candidate is not logged in and clicks on valid link' do
    given_i_am_not_signed_in
    and_i_visit_the_unsubscribe_link_with_valid_token
    then_i_am_unsubscribed
    and_i_see_unsubscribe_confirmation
  end

  scenario 'Candidate visits link with invalid token' do
    given_i_am_signed_in
    and_i_visit_a_bad_unsubscribe_link
    then_i_see_a_404
  end

  scenario 'Candidate has multiple tokens generated' do
    given_i_am_signed_in
    and_multiple_tokens_have_been_generated
    when_i_click_on_a_link_with_any_of_the_tokens
    then_i_am_unsubscribed
    and_i_see_unsubscribe_confirmation

    given_i_click_on_another_link
    then_i_see_unsubscribe_confirmation
  end

private

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in
    current_candidate
  end

  def and_multiple_tokens_have_been_generated
    @tokens = (1..2).map { current_candidate.generate_token_for :unsubscribe_link }
  end

  def when_i_click_on_a_link_with_any_of_the_tokens
    token = @tokens.sample
    visit candidate_interface_unsubscribe_from_emails_path(token:)
  end
  alias_method :given_i_click_on_another_link, :when_i_click_on_a_link_with_any_of_the_tokens

  def and_i_visit_the_unsubscribe_link_with_valid_token
    token = current_candidate.generate_token_for :unsubscribe_link
    visit candidate_interface_unsubscribe_from_emails_path(token:)
  end

  def and_i_visit_a_bad_unsubscribe_link
    token = 'something-useless'
    visit candidate_interface_unsubscribe_from_emails_path(token:)
  end

  def then_i_am_unsubscribed
    expect(current_candidate.reload.unsubscribed_from_emails).to be true
  end

  def and_i_see_unsubscribe_confirmation
    expect(page).to have_content 'You have successfully unsubscribed'
  end
  alias_method :then_i_see_unsubscribe_confirmation, :and_i_see_unsubscribe_confirmation
  def and_i_am_on_application_details_page
    expect(page).to have_current_path candidate_interface_continuous_applications_details_path, ignore_query: true
  end

  def and_i_am_on_the_sign_in_page
    expect(page).to have_current_path candidate_interface_sign_in_path, ignore_query: true
  end

  def then_i_see_a_404
    expect(page).to have_content 'Page not found'
  end
end
