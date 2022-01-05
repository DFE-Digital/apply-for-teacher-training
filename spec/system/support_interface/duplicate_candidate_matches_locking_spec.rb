require 'rails_helper'

RSpec.feature 'See Duplicate candidate matches' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2021, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'Support agent visits Duplicate candidate matches page', sidekiq: true do
    given_i_am_a_support_user
    and_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_fraud_matches_worker_has_run
    and_a_candidate_has_a_locked_account

    when_i_view_the_locked_candidate
    then_i_can_see_a_warning_message
    and_i_cannot_impersonate_the_candidate

    when_i_view_the_unlocked_candidate
    then_i_cannot_see_a_warning_message
    and_i_can_impersonate_the_candidate
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_with_duplicate_applications_in_the_system
    @candidate_one = create(:candidate, email_address: 'exemplar1@example.com')
    @candidate_two = create(:candidate, email_address: 'exemplar2@example.com')

    @application_form_one = create(:application_form, candidate: @candidate_one, first_name: 'Jeffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @application_form_two = create(:application_form, candidate: @candidate_two, first_name: 'Joffrey', last_name: 'Thompson', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
  end

  def and_a_candidate_has_a_locked_account
    @candidate_one.update!(account_locked: true)
  end

  def and_the_update_fraud_matches_worker_has_run
    UpdateFraudMatchesWorker.perform_async
  end

  def when_i_view_the_locked_candidate
    visit support_interface_application_form_path(application_form_id: @application_form_one.id)
  end

  def then_i_can_see_a_warning_message
    expect(page).to have_content('Account locked')
  end

  def and_i_cannot_impersonate_the_candidate
    expect(page).not_to have_button('Sign in as this candidate')
  end

  def when_i_view_the_unlocked_candidate
    visit support_interface_application_form_path(application_form_id: @application_form_two.id)
  end

  def then_i_cannot_see_a_warning_message
    expect(page).not_to have_content('Account locked')
  end

  def and_i_can_impersonate_the_candidate
    expect(page).to have_button('Sign in as this candidate')
  end
end
