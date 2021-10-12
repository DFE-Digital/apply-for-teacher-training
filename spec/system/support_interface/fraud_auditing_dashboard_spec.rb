require 'rails_helper'

RSpec.feature 'See Fraud Auditing matches' do
  include DfESignInHelpers

  scenario 'Support agent visits Fraud Auditing Dashboard page', sidekiq: true do
    given_i_am_a_support_user
    and_the_feature_flag_is_active
    and_i_go_to_fraud_auditing_dashboard_page
    then_i_should_see_a_message_declaring_that_there_are_no_matches

    when_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_fraud_matches_worker_has_run
    and_i_go_to_fraud_auditing_dashboard_page
    then_i_should_see_list_of_fraud_auditing_matches

    when_i_mark_a_match_as_fradulent
    then_i_see_that_the_match_is_marked_as_fraudulent

    when_i_mark_a_match_as_non_fradulent
    then_i_see_that_the_match_is_marked_as_non_fraudulent
    when_i_select_a_candidate_to_block
    and_i_click_continue
    then_i_am_told_to_confirm_i_have_followed_the_guidance

    when_i_confirm_my_choice
    and_i_click_continue
    then_i_should_see_an_updated_dashboard
    and_the_fraud_match_should_be_set_as_blocked

    when_i_unblock_the_candidate
    and_i_click_continue
    then_i_am_told_to_confirm_i_have_followed_the_guidance

    when_i_confirm_my_choice
    and_i_click_continue
    then_i_should_see_the_dashboard_updated_again
    and_the_fraud_match_should_be_set_as_unblocked
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_the_feature_flag_is_active
    FeatureFlag.activate(:block_fraudulent_submission)
  end

  def then_i_should_see_a_message_declaring_that_there_are_no_matches
    expect(page).to have_content 'There are currently no duplicate applications matched on these criteria'
  end

  def when_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com')

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now - 7.days)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
  end

  def and_the_update_fraud_matches_worker_has_run
    UpdateFraudMatchesWorker.perform_async
  end

  def and_i_go_to_fraud_auditing_dashboard_page
    visit support_interface_fraud_auditing_matches_path
  end

  def then_i_should_see_list_of_fraud_auditing_matches
    within 'td:eq(1)' do
      expect(page).to have_content 'Thompson'
    end

    within 'td:eq(2)' do
      expect(page).to have_content 'Jeffrey'
      expect(page).to have_content 'Joffrey'
    end

    within 'td:eq(3)' do
      expect(page).to have_link @candidate_one.email_address
      expect(page).to have_link @candidate_two.email_address
    end

    within 'td:eq(4)' do
      expect(page).to have_content ''
    end

    within 'td:eq(5)' do
      expect(page).to have_content ''
    end

    within 'td:eq(6)' do
      expect(page).to have_content 'No'
      expect(page).to have_link 'Mark as fraudulent'
    end

    within 'td:eq(7)' do
      expect(page).to have_content 'Yes'
      expect(page).to have_content 'No'
    end

    within 'td:eq(8)' do
      expect(page).to have_content 'Block'
    end
  end

  def when_i_mark_a_match_as_fradulent
    within 'td:eq(6)' do
      click_link 'Mark as fraudulent'
    end
  end

  def then_i_see_that_the_match_is_marked_as_fraudulent
    within 'td:eq(6)' do
      expect(page).to have_content 'Yes'
      expect(page).to have_link 'Mark as non fraudulent'
    end
  end

  def when_i_mark_a_match_as_non_fradulent
    within 'td:eq(6)' do
      click_link 'Mark as non fraudulent'
    end
  end

  def then_i_see_that_the_match_is_marked_as_non_fraudulent
    within 'td:eq(6)' do
      expect(page).to have_content 'No'
      expect(page).to have_link 'Mark as fraudulent'
    end
  end

  def when_i_select_a_candidate_to_block
    click_link 'Block'
  end

  def and_i_click_continue
    click_button 'Continue'
  end

  def then_i_am_told_to_confirm_i_have_followed_the_guidance
    expect(page).to have_content 'Select that you have read the guidance'
  end

  def when_i_confirm_my_choice
    check 'I have read the guidance'
  end

  def then_i_should_see_an_updated_dashboard
    within 'td:eq(8)' do
      expect(page).to have_content 'Unblock'
    end
  end

  def and_the_fraud_match_should_be_set_as_blocked
    blocked_candidate = FraudMatch.first
    expect(blocked_candidate.blocked).to eq true
    expect(blocked_candidate.fraudulent?).to eq true
  end

  def when_i_unblock_the_candidate
    click_link 'Unblock'
  end

  def then_i_should_see_the_dashboard_updated_again
    within 'td:eq(8)' do
      expect(page).to have_content 'Block'
    end
  end

  def and_the_fraud_match_should_be_set_as_unblocked
    unblocked_candidate = FraudMatch.first
    expect(unblocked_candidate.blocked).to eq false
    expect(unblocked_candidate.fraudulent?).to eq false
  end
end
