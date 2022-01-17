require 'rails_helper'

RSpec.feature 'Editing account status' do
  include DfESignInHelpers

  scenario 'Support user edits account status' do
    given_i_am_a_support_user
    and_the_duplicate_matching_feature_flag_is_activated
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    and_i_click_on_the_email_address_link
    and_click_on_block_account_link
    then_i_should_see_three_options
    and_unblocked_should_be_selected
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_the_duplicate_matching_feature_flag_is_activated
    FeatureFlag.activate(:duplicate_matching)
  end

  def and_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com')

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
  end

  def and_the_update_duplicate_matches_worker_has_run
    UpdateFraudMatchesWorker.perform_async
  end

  def when_i_go_to_duplicate_matches_page
    visit support_interface_duplicate_matches_path
  end

  def and_i_click_the_duplicate_matches_tab
    click_link 'Candidates'
    click_link 'Duplicate candidate matches'
  end

  def and_i_click_on_the_match_link
    click_link '2 candidates with postcode W6 9BH and DOB 8 Aug 1998'
  end

  def and_i_click_on_the_email_address_link
    click_link 'exemplar1@example.com'
  end

  def and_click_on_block_account_link
    click_link 'Block Account'
  end

  def then_i_should_see_three_options
    expect(page).to have_text 'Account submission blocked'
    expect(page).to have_text 'Account access locked (user cannot sign in)'
    expect(page).to have_text 'Unblocked'
  end

  def and_unblocked_should_be_selected
    expect(find_field('Unblocked').checked?).to be_truthy
    expect(find_field('Account submission blocked').checked?).to be_falsey
    expect(find_field('Account access locked (user cannot sign in)').checked?).to be_falsey
  end
end
