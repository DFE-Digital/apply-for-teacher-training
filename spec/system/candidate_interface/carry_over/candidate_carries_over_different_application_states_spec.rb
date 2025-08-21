require 'rails_helper'

RSpec.describe 'Carry over application to a new cycle in different states', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  before do
    @candidate = create(:candidate)
    @current_year = current_year
    @previous_year = previous_year
    @next_year = next_year
    @application_form = create(:application_form, :completed, recruitment_cycle_year: @previous_year, candidate: @candidate)
  end

  scenario 'Candidate sees complete page when submitted at has value but courses choices does not have submission' do
    given_i_have_an_empty_submitted_application_from_last_cycle
    and_i_am_signed_in_as_a_candidate
    and_i_visit_the_application_dashboard
    then_i_see_the_carry_over_content
  end

  scenario 'Candidate carries over empty application to new cycle through the carry over interstitial' do
    given_i_have_an_empty_application_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle_using_the_carry_over_interstitial
  end

  scenario 'Candidate carries over unsubmitted application to new cycle through the carry over interstitial' do
    given_i_have_an_unsubmitted_application_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle_using_the_carry_over_interstitial
  end

  scenario 'Candidate carries over application_not_sent application to new cycle' do
    given_i_have_an_application_not_sent_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle
  end

  scenario 'Candidate carries over conditions_not_met application to new cycle' do
    given_i_have_an_application_conditions_not_met_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle
  end

  scenario 'Candidate carries over offer_withdrawn application to new cycle' do
    given_i_have_an_application_offer_withdrawn_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle
  end

  scenario 'Candidate carries over declined application to new cycle' do
    given_i_have_an_application_declined_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle
  end

  scenario 'Candidate carries over withdrawn application to new cycle' do
    given_i_have_an_application_withdrawn_from_last_cycle
    then_i_can_carry_over_my_application_to_the_new_cycle
  end

  scenario 'Candidate does not need to carry over recruited application' do
    given_i_have_an_application_recruited_from_last_cycle
    and_i_am_signed_in_as_a_candidate
    when_i_visit_any_page
    then_i_am_on_the_post_offer_dashboard
  end

  scenario 'Candidate does not need to carry over pending conditions application' do
    given_i_have_an_application_pending_conditions_from_last_cycle
    and_i_am_signed_in_as_a_candidate
    when_i_visit_any_page
    then_i_am_on_the_post_offer_dashboard
  end

  def given_i_have_an_empty_submitted_application_from_last_cycle
    @application_form.update!(submitted_at: 1.year.ago)
    @application_form.application_choices.delete_all
  end

  def given_i_have_an_empty_application_from_last_cycle
    @application_form.update!(submitted_at: nil)
    @application_form.application_choices.delete_all
  end

  def given_i_have_an_unsubmitted_application_from_last_cycle
    @application_form.update!(submitted_at: nil)
    create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def given_i_have_an_application_conditions_not_met_from_last_cycle
    create(:application_choice, :conditions_not_met, application_form: @application_form)
  end

  def given_i_have_an_application_offer_withdrawn_from_last_cycle
    create(:application_choice, :offer_withdrawn, application_form: @application_form)
  end

  def given_i_have_an_application_declined_from_last_cycle
    create(:application_choice, :declined, application_form: @application_form)
  end

  def given_i_have_an_application_withdrawn_from_last_cycle
    create(:application_choice, :withdrawn, application_form: @application_form)
  end

  def given_i_have_an_application_not_sent_from_last_cycle
    create(:application_choice, :application_not_sent, application_form: @application_form)
  end

  def given_i_have_an_application_recruited_from_last_cycle
    create(:application_choice, :recruited, application_form: @application_form)
  end

  def given_i_have_an_application_pending_conditions_from_last_cycle
    create(:application_choice, :accepted, application_form: @application_form)
  end

  def then_i_can_carry_over_my_application_to_the_new_cycle
    and_i_am_signed_in_as_a_candidate
    and_i_visit_the_application_dashboard
    then_i_am_ask_to_apply_for_courses_into_the_new_recruitment_cycle
    when_i_carry_over
    then_my_application_is_into_the_new_cycle
    and_i_am_in_your_details_page
  end

  def then_i_can_carry_over_my_application_to_the_new_cycle_using_the_carry_over_interstitial
    and_i_am_signed_in_as_a_candidate
    and_i_visit_the_application_dashboard
    then_i_am_ask_to_apply_for_courses_into_the_new_recruitment_cycle
    when_i_carry_over_through_carry_over_interstitial
    then_my_application_is_into_the_new_cycle
    and_i_am_in_your_details_page
  end

  def and_i_am_signed_in_as_a_candidate
    login_as(@candidate)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      :eligible_for_free_school_meals,
      :with_gcses,
      submitted_at: nil,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
      references_count: 0,
    )
    @application_choice = create(
      :application_choice,
      status: :unsubmitted,
      application_form: @application_form,
    )
    @first_reference = create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
    @second_reference = create(
      :reference,
      feedback_status: :feedback_requested,
      application_form: @application_form,
    )
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
  end

  def and_i_visit_the_application_dashboard
    visit root_path
  end

  def then_i_am_ask_to_apply_for_courses_into_the_new_recruitment_cycle
    expect(page).to have_content("courses starting in the #{@previous_year} to #{@current_year} academic year, which have now closed.")
    expect(page).to have_content("apply for courses starting in the #{@current_year} to #{@next_year} academic year instead.")
    then_i_see_the_carry_over_content
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Continue'
    end
  end

  def when_i_carry_over
    click_link_or_button 'Continue'
  end

  def then_my_application_is_into_the_new_cycle
    expect(@candidate.application_forms.pluck(:recruitment_cycle_year)).to contain_exactly(@previous_year, @current_year)
    expect(@candidate.current_application.recruitment_cycle_year).to be(@current_year)
  end

  def and_i_am_in_your_details_page
    expect(page).to have_current_path(candidate_interface_details_path)
  end

  def when_i_visit_any_page
    visit root_path
  end

  def then_i_am_on_the_post_offer_dashboard
    expect(page).to have_current_path(candidate_interface_application_offer_dashboard_path)
  end

  def when_i_carry_over_through_carry_over_interstitial
    click_link_or_button 'Continue'
  end
end
