require 'rails_helper'

RSpec.describe 'Swapping candidate email addresses' do
  include DfESignInHelpers

  scenario 'Support user swaps candidate email addresses for two matched accounts' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    then_i_see_the_information_for_both_candidates

    when_i_click_on_change_email_address_for_the_first_candidate
    then_i_see_the_change_email_address_page_for_the_first_candidate

    when_i_click_on_change_email_address
    then_i_see_a_validation_error_for_not_selecting_an_email_address

    when_i_select_the_second_candidate_email_address
    and_i_click_on_change_email_address
    then_i_see_that_the_candidates_email_address_has_been_changed
    and_the_candidates_email_addresses_have_been_swapped
  end

  scenario 'Support user enters another email address for a candidate' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    then_i_see_the_information_for_both_candidates

    when_i_click_on_change_email_address_for_the_first_candidate
    then_i_see_the_change_email_address_page_for_the_first_candidate

    when_i_select_other_email_address_option
    and_i_click_on_change_email_address
    then_i_see_a_validation_error_for_not_entering_another_email_address

    when_i_enter_another_email_address
    and_i_click_on_change_email_address
    then_i_see_that_the_candidates_email_address_has_been_changed
    and_the_candidates_email_addresses_changed_to_the_new_email_address
  end

  scenario 'Support user enters another email address that is already linked to another active account' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    then_i_see_the_information_for_both_candidates

    when_i_click_on_change_email_address_for_the_first_candidate
    then_i_see_the_change_email_address_page_for_the_first_candidate

    when_i_select_other_email_address_option
    and_i_enter_another_email_address_that_is_already_linked_to_another_active_account
    and_i_click_on_change_email_address
    then_i_see_a_validation_error_for_entering_an_email_address_linked_to_another_candidates_account
  end

  scenario 'Support user can not swap email addresses with a matched candidate with a active account' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run
    and_the_second_candidate_has_an_active_account

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    then_i_see_the_information_for_both_candidates

    when_i_click_on_change_email_address_for_the_first_candidate
    then_i_do_not_see_the_email_address_of_the_second_candidate_as_an_option

    when_i_select_other_email_address_option
    and_i_enter_another_email_address_for_the_second_candidate
    and_i_click_on_change_email_address
    then_i_see_a_validation_error_for_entering_an_email_address_linked_to_another_candidates_account
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com', created_at: 1.month.ago, account_locked: true)

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
  end

  def and_the_second_candidate_has_an_active_account
    @candidate_two.update!(account_locked: false)
  end

  def and_the_update_duplicate_matches_worker_has_run
    UpdateDuplicateMatchesWorker.perform_now
    Candidate.update_all(submission_blocked: false) # to test the account status we need a clean slate
  end

  def when_i_go_to_duplicate_matches_page
    visit support_interface_duplicate_matches_path
  end

  def and_i_click_the_duplicate_matches_tab
    click_link_or_button 'Candidates'
    click_link_or_button 'Duplicate candidate matches'
  end

  def and_i_click_on_the_match_link
    click_link_or_button '2 candidates with postcode W6 9BH and DOB 8 Aug 1998'
  end

  def then_i_see_the_information_for_both_candidates
    expect(page).to have_text('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(page).to have_text('exemplar1@example.com')
    expect(page).to have_text('exemplar2@example.com')
  end

  def when_i_click_on_change_email_address_for_the_first_candidate
    click_on 'Change email address', match: :first
  end

  def when_i_click_on_change_email_address
    click_on 'Change email address'
  end
  alias_method :and_i_click_on_change_email_address, :when_i_click_on_change_email_address

  def then_i_see_the_change_email_address_page_for_the_first_candidate
    expect(page).to have_element(:span, text: 'exemplar1@example.com')
    expect(page).to have_element(:h1, text: 'Change email address')

    expect(page).to have_element(:legend, text: 'What email address should this account use?')
    expect(page).to have_field('exemplar2@example.com', type: :radio)
    expect(page).to have_field('Other email address', type: :radio)
  end

  def then_i_see_a_validation_error_for_not_selecting_an_email_address
    expect(page).to have_text('Select an email address')
  end

  def when_i_select_the_second_candidate_email_address
    choose 'exemplar2@example.com'
  end

  def then_i_see_that_the_candidates_email_address_has_been_changed
    expect(page).to have_text('Email address updated')
  end

  def and_the_candidates_email_addresses_have_been_swapped
    expect(@candidate_one.reload.email_address).to eq('exemplar2@example.com')
    expect(@candidate_two.reload.email_address).to eq('exemplar1@example.com')
  end

  def when_i_select_other_email_address_option
    choose 'Other email address'
  end

  def then_i_see_a_validation_error_for_not_entering_another_email_address
    expect(page).to have_text('Enter an email address')
  end

  def when_i_enter_another_email_address
    fill_in 'Enter email address', with: 'new_email@example.com'
  end

  def and_the_candidates_email_addresses_changed_to_the_new_email_address
    expect(@candidate_one.reload.email_address).to eq('new_email@example.com')
  end

  def and_i_enter_another_email_address_that_is_already_linked_to_another_active_account
    fill_in 'Enter email address', with: create(:candidate).email_address
  end

  def then_i_see_a_validation_error_for_entering_an_email_address_linked_to_another_candidates_account
    expect(page).to have_text('This email address is already linked to another active account.')
  end

  def then_i_do_not_see_the_email_address_of_the_second_candidate_as_an_option
    expect(page).to have_no_field('exemplar2@example.com', type: :radio)
  end

  def and_i_enter_another_email_address_for_the_second_candidate
    fill_in 'Enter email address', with: @candidate_two.email_address
  end
end
