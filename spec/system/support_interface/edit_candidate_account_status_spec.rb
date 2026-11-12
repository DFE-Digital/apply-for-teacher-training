require 'rails_helper'

RSpec.describe 'Editing account status' do
  include DfESignInHelpers

  scenario 'Support user edits account status' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    and_i_click_on_the_email_address_link
    and_click_on_block_account_link
    then_i_see_three_options
    and_unblocked_is_selected

    and_i_choose_account_access_locked
    when_i_click_continue
    then_i_see_candidate_account_status_as_access_locked

    when_i_click_to_change_candidate_account_status
    and_account_access_locked_is_selected
    and_i_choose_account_submission_blocked
    when_i_click_continue
    then_i_see_candidate_account_status_as_submission_blocked

    when_i_click_to_change_candidate_account_status
    and_account_submission_blocked_is_selected
  end

  scenario 'Support user edits account status from the summary page' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    then_i_see_the_information_for_both_candidates

    when_i_click_on_lock_account_for_the_first_candidate
    then_i_see_that_the_account_has_been_locked
    and_the_candidates_account_status_has_been_locked

    when_i_click_on_unlock_account_for_the_first_candidate
    then_i_see_that_the_account_has_been_unlocked
    and_the_candidates_account_status_has_been_unlocked
  end

  scenario 'Support user edits account status and unlocks all accounts' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_duplicate_matches_worker_has_run
    and_both_candidates_have_locked_accounts

    when_i_go_to_duplicate_matches_page
    and_i_click_the_duplicate_matches_tab
    and_i_click_on_the_match_link
    then_i_see_the_information_for_both_candidates

    when_i_click_on_unlock_all
    then_i_see_that_all_the_accounts_have_been_unlocked
    and_all_account_statuses_has_been_unlocked
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com', created_at: 1.month.ago)

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
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

  def and_i_click_on_the_email_address_link
    click_link_or_button 'exemplar1@example.com'
  end

  def and_click_on_block_account_link
    click_link_or_button 'Block account'
  end

  def then_i_see_three_options
    expect(page).to have_text 'Account submission blocked'
    expect(page).to have_text 'Account access locked (user cannot sign in)'
    expect(page).to have_text 'Unblocked'
  end

  def and_unblocked_is_selected
    expect(unblocked_field.checked?).to be_truthy
    expect(account_submission_blocked_field.checked?).to be_falsey
    expect(account_access_locked_field.checked?).to be_falsey
  end

  def and_i_choose_account_access_locked
    choose 'Account access locked (user cannot sign in)'
  end

  def and_i_choose_account_submission_blocked
    choose 'Account submission blocked'
  end

  def when_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_see_candidate_account_status_as_access_locked
    expect(page).to have_text('Account access locked')
  end

  def then_i_see_candidate_account_status_as_submission_blocked
    expect(page).to have_text('Account submission blocked')
  end

  def when_i_click_to_change_candidate_account_status
    click_link_or_button 'Change'
  end

  def and_account_access_locked_is_selected
    expect(unblocked_field.checked?).to be_falsey
    expect(account_submission_blocked_field.checked?).to be_falsey
    expect(account_access_locked_field.checked?).to be_truthy
  end

  def and_account_submission_blocked_is_selected
    expect(unblocked_field.checked?).to be_falsey
    expect(account_submission_blocked_field.checked?).to be_truthy
    expect(account_access_locked_field.checked?).to be_falsey
  end

  def unblocked_field
    find_field('Unblocked')
  end

  def account_access_locked_field
    find_field('Account access locked (user cannot sign in)')
  end

  def account_submission_blocked_field
    find_field('Account submission blocked')
  end

  def then_i_see_the_information_for_both_candidates
    expect(page).to have_text('2 candidates with postcode W6 9BH and DOB 8 Aug 1998')
    expect(page).to have_text('exemplar1@example.com')
    expect(page).to have_text('exemplar2@example.com')
  end

  def when_i_click_on_lock_account_for_the_first_candidate
    click_on 'Lock account', match: :first
  end

  def then_i_see_that_the_account_has_been_locked
    expect(page).to have_text('This account has been locked')
  end

  def and_the_candidates_account_status_has_been_locked
    expect(@candidate_one.reload.account_locked?).to be_truthy
    expect(@candidate_one.reload.submission_blocked?).to be_falsey

    expect(@candidate_two.reload.account_locked?).to be_falsey
    expect(@candidate_two.reload.submission_blocked?).to be_falsey
  end

  def when_i_click_on_unlock_account_for_the_first_candidate
    click_on 'Unlock account', match: :first
  end

  def then_i_see_that_the_account_has_been_unlocked
    expect(page).to have_text('This account has been unlocked')
    expect(page).to have_text('There are currently 2 accounts unlocked.')
  end

  def and_the_candidates_account_status_has_been_unlocked
    expect(@candidate_one.reload.account_locked?).to be_falsey
    expect(@candidate_one.reload.submission_blocked?).to be_falsey

    expect(@candidate_two.reload.account_locked?).to be_falsey
    expect(@candidate_two.reload.submission_blocked?).to be_falsey
  end
  alias_method :and_all_account_statuses_has_been_unlocked, :and_the_candidates_account_status_has_been_unlocked

  def and_both_candidates_have_locked_accounts
    @candidate_one.update(account_locked: true)
    @candidate_two.update(account_locked: true)
  end

  def when_i_click_on_unlock_all
    click_on 'Unlock all'
  end

  def then_i_see_that_all_the_accounts_have_been_unlocked
    expect(page).to have_text('These accounts have been unlocked')
  end
end
