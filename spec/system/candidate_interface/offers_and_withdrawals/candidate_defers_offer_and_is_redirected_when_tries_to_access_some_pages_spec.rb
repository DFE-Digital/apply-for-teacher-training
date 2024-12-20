require 'rails_helper'

RSpec.describe 'Candidate is redirected when tries to see your details after deferring an offer' do
  include CandidateHelper

  scenario 'Candidate views their deferred offer on the post offer dashboard' do
    given_i_am_signed_in
    and_i_have_a_deferred_offer

    when_i_visit_the_application_dashboard
    then_i_see_the_post_offer_dashboard

    when_i_click_to_view_my_submitted_application
    and_i_click_back_to_my_offer
    then_i_see_the_post_offer_dashboard

    when_i_click_to_withdraw_my_application
    and_i_click_back_to_my_offer
    then_i_see_the_post_offer_dashboard

    when_i_try_to_enter_a_specific_section
    then_i_see_the_post_offer_dashboard
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_a_deferred_offer
    @application_form = create(:completed_application_form, candidate: @candidate, recruitment_cycle_year: 2024)
    @pending_reference = create(:reference, :feedback_requested, reminder_sent_at: nil, application_form: @application_form)
    @completed_reference = create(:reference, :feedback_provided, application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :offer_deferred,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_choices_path
  end

  def then_i_see_the_post_offer_dashboard
    expect(page).to have_current_path(candidate_interface_application_offer_dashboard_path)

    expect(page).to have_content("Your deferred offer for #{@application_choice.current_course.name_and_code}")
    expect(page).to have_content("You have chosen to defer your offer from #{@application_choice.course_option.course.provider.name} to study #{@application_choice.course.name_and_code}.")
    expect(page).to have_content('References')
    expect(page).to have_content('Offer conditions')
    expect(page).to have_content("#{@application_choice.offer.conditions.first.text} Pending", normalize_ws: true)
  end

  def when_i_click_to_view_my_submitted_application
    click_link_or_button 'View application'
  end

  def when_i_click_to_withdraw_my_application
    click_link_or_button 'Withdraw from the course'
  end

  def and_i_click_back_to_my_offer
    click_link_or_button 'Back to your offer'
  end

  def when_i_try_to_enter_a_specific_section
    visit candidate_interface_edit_safeguarding_path
  end
end
