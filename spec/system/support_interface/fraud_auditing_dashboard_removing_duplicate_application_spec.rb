require 'rails_helper'

RSpec.feature 'See Fraud Auditing matches' do
  include DfESignInHelpers
  include CandidateHelper

  scenario 'Support agent visits Fraud Auditing Dashboard page' do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system

    when_i_go_to_fraud_auditing_dashboard_page
    and_i_click_to_remove_access_from_the_second_candidate
    then_i_see_the_confirm_remove_access_page

    when_i_click_continue
    then_i_am_told_i_need_to_confirm_i_have_read_the_guidance

    when_i_check_confirm_that_i_have_read_the_guidance
    and_i_click_continue
    then_i_see_the_fraud_auditing_dashboard
    and_that_candidate_two_has_had_their_email_updated_to_the_correct_value
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com')

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: Time.zone.now - 7.days)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: nil)

    @fraud_match = create(:fraud_match, candidates: [@candidate_one, @candidate_two])
  end

  def when_i_go_to_fraud_auditing_dashboard_page
    visit support_interface_fraud_auditing_matches_path
  end

  def and_i_click_to_remove_access_from_the_second_candidate
    click_link 'Remove Joffrey Thompson'
  end

  def then_i_see_the_confirm_remove_access_page
    expect(page).to have_current_path support_interface_fraud_auditing_matches_confirm_remove_access_path(@fraud_match.id, @candidate_two.id)
  end

  def when_i_click_continue
    click_button t('continue')
  end
  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_am_told_i_need_to_confirm_i_have_read_the_guidance
    expect_validation_error 'Confirm that you have read the guidance'
  end

  def when_i_check_confirm_that_i_have_read_the_guidance
    check 'I have read the guidance'
  end

  def then_i_see_the_fraud_auditing_dashboard
    expect(page).to have_current_path support_interface_fraud_auditing_matches_path
  end

  def and_that_candidate_two_has_had_their_email_updated_to_the_correct_value
    expect(page).to have_content @candidate_one.email_address
    expect(page).to have_content "fraud-match-id-#{@fraud_match.id}-candidate-id-#{@candidate_two.id}-#{@candidate_two.email_address}"
  end
end
