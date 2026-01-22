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

    when_i_navigate_to_my_applications
    then_i_see_the_recruitment_deadline_page
    and_i_see_information_to_apply_for_the_next_academic_year
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
  end

  def when_i_navigate_to_my_applications
    click_on 'Your applications'
  end

  def then_i_see_the_recruitment_deadline_page
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_element(:h1, text: 'The recruitment deadline has now passed')
    expect(page).to have_element(
      :p,
      text: "The deadline for applying to courses in the #{@application_form.academic_year_range_name} " \
            'academic year has passed. You can no longer apply to courses starting in ' \
            "#{@application_form.recruitment_cycle_timetable.apply_deadline_at.to_fs(:month_and_year)}.",
    )
  end

  def and_i_see_information_to_apply_for_the_next_academic_year
    expect(page).to have_element(
      :h2,
      text: "Apply to courses in the #{RecruitmentCycleTimetable.next_timetable.academic_year_range_name} academic year",
    )
  end
end
