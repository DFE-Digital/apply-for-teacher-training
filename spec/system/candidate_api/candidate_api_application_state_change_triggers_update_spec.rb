require 'rails_helper'

RSpec.describe 'Candidate API application status change' do
  include SignInHelper
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
  end

  it 'candidate_api_updated_at is updated when each state transition occurs' do
    when_i_sign_up
    then_my_application_status_is_never_signed_in
    and_my_candidate_api_updated_at_has_been_updated

    when_i_confirm_account_creation
    then_my_application_status_is_unsubmitted_not_started_form
    and_my_sign_in_updates_my_candidate_api_updated_at

    when_i_complete_a_field_on_my_application_form
    then_my_application_status_is_unsubmitted_in_progress
    and_my_first_update_updates_my_candidate_api_updated_at

    when_i_submit_my_application
    then_my_application_status_is_awaiting_provider_decisions
    and_my_submission_updates_my_candidate_api_updated_at

    when_i_receive_a_rejection
    then_my_application_status_is_ended_without_success
    and_the_rejection_updates_my_candidate_api_updated_at

    when_i_receive_an_offer_with_conditions
    then_my_application_status_is_awaiting_candidate_response
    and_the_offer_updates_my_candidate_api_updated_at

    when_i_accept_my_offer
    then_my_application_status_is_pending_conditions
    and_my_acceptance_updates_my_candidate_api_updated_at

    when_i_meet_my_conditions
    then_my_application_status_is_recruited
    and_me_being_recruited_updates_my_candidate_api_updated_at

    when_i_defer
    then_my_application_status_is_offer_deferred
    and_the_deferal_updates_my_candidate_api_updated_at
  end

  def when_i_sign_up
    @email = "#{SecureRandom.hex}@example.com"
    visit candidate_interface_sign_up_path
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_link_or_button t('continue')
  end

  def then_my_application_status_is_never_signed_in
    @candidate = Candidate.last
    expect(ApplicationFormStateInferrer.new(@candidate.application_forms.last).state).to eq :never_signed_in
  end

  def and_my_candidate_api_updated_at_has_been_updated
    expect(@candidate.candidate_api_updated_at).to eq(Time.zone.now)
  end

  def when_i_sign_in
    travel_temporarily_to(1.minute.from_now) do
      open_email(@email)
      click_magic_link_in_email
      confirm_sign_in
    end
  end

  def when_i_confirm_account_creation
    travel_temporarily_to(1.minute.from_now) do
      open_email(@email)
      click_magic_link_in_email
      confirm_create_account
    end
  end

  def then_my_application_status_is_unsubmitted_not_started_form
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :unsubmitted_not_started_form
  end

  def and_my_sign_in_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 1.minute.from_now
  end

  def when_i_complete_a_field_on_my_application_form
    travel_temporarily_to(10.minutes.from_now) do
      candidate_completes_application_form(candidate: @candidate)
    end
  end

  def then_my_application_status_is_unsubmitted_in_progress
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :unsubmitted_in_progress
  end

  def and_my_first_update_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 10.minutes.from_now
  end

  def when_i_submit_my_application
    travel_temporarily_to(20.minutes.from_now) do
      candidate_submits_application
    end
  end

  def then_my_application_status_is_awaiting_provider_decisions
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :awaiting_provider_decisions
  end

  def and_my_submission_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 20.minutes.from_now
  end

  def when_i_receive_a_rejection
    travel_temporarily_to(30.minutes.from_now) do
      ApplicationStateChange.new(@candidate.application_choices.first).reject!
    end
  end

  def then_my_application_status_is_ended_without_success
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :ended_without_success
  end

  def and_the_rejection_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 30.minutes.from_now
  end

  def when_i_receive_an_offer_with_conditions
    travel_temporarily_to(40.minutes.from_now) do
      @candidate.application_choices.first.update!(status: 'awaiting_provider_decision', offer: create(:offer))
      ApplicationStateChange.new(@candidate.application_choices.first).make_offer!
    end
  end

  def then_my_application_status_is_awaiting_candidate_response
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :awaiting_candidate_response
  end

  def and_the_offer_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 40.minutes.from_now
  end

  def when_i_accept_my_offer
    travel_temporarily_to(50.minutes.from_now) do
      ApplicationStateChange.new(@candidate.application_choices.first).accept!
    end
  end

  def then_my_application_status_is_pending_conditions
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :pending_conditions
  end

  def and_my_acceptance_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 50.minutes.from_now
  end

  def when_i_meet_my_conditions
    travel_temporarily_to(60.minutes.from_now) do
      ApplicationStateChange.new(@candidate.application_choices.first).confirm_conditions_met!
    end
  end

  def then_my_application_status_is_recruited
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :recruited
  end

  def and_me_being_recruited_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 60.minutes.from_now
  end

  def when_i_defer
    travel_temporarily_to(70.minutes.from_now) do
      ApplicationStateChange.new(@candidate.application_choices.first).defer_offer!
    end
  end

  def then_my_application_status_is_offer_deferred
    expect(ApplicationFormStateInferrer.new(@candidate.reload.application_forms.last).state).to eq :offer_deferred
  end

  def and_the_deferal_updates_my_candidate_api_updated_at
    expect(@candidate.candidate_api_updated_at).to eq 70.minutes.from_now
  end
end
