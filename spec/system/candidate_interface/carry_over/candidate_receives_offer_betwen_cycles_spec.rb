require 'rails_helper'

RSpec.describe 'Candidate receives an offer between cycles' do
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
    @application_form = create(:completed_application_form)
    @candidate = @application_form.candidate
  end

  scenario 'candidate can reject offer' do
    given_i_am_awaiting_provider_decision
    and_the_apply_deadline_passes
    when_the_provider_makes_an_offer
    and_i_sign_in
    and_i_navigate_to_my_application_choices
    then_i_can_navigate_to_the_offer
    and_i_can_decline_the_offer
    and_i_can_carry_over_my_application
  end

  scenario 'candidate can accept offer' do
    given_i_am_awaiting_provider_decision
    and_the_apply_deadline_passes
    when_the_provider_makes_an_offer
    and_i_sign_in
    and_i_navigate_to_my_application_choices
    then_i_can_navigate_to_the_offer
    and_i_can_accept_the_offer
  end

private

  def given_i_am_awaiting_provider_decision
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @application_form)
  end

  def and_i_sign_in
    login_as @candidate
    visit root_path
  end

  def and_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def when_the_provider_makes_an_offer
    create(:unconditional_offer, application_choice: @application_choice)
    ApplicationStateChange.new(@application_choice).make_offer!
  end

  def and_i_navigate_to_my_application_choices
    click_on 'Your applications'
  end

  def and_i_can_decline_the_offer
    choose 'Decline offer'
    click_on 'Continue'
    click_on 'Yes I’m sure – decline this offer'
    expect(page).to have_content 'You have declined your offer'
    expect(@application_choice.reload.status).to eq 'declined'
  end

  def and_i_can_accept_the_offer
    choose 'Accept offer'
    click_on 'Continue'
    click_on 'Accept offer'
    expect(page).to have_content 'You have accepted your offer'
  end

  def then_i_can_navigate_to_the_offer
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'Offer received'
    click_on @application_choice.provider.name
  end

  def and_i_can_carry_over_my_application
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      click_on 'Update your details'
    end

    expect(page).to have_current_path candidate_interface_details_path
  end
end
