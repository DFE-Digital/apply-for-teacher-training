require 'rails_helper'

RSpec.describe 'Candidate submits an application up to 4 choices' do
  include CandidateHelper

  before do
    given_courses_exist
    FeatureFlag.activate(:candidate_preferences)
  end

  scenario 'when candidate has a conditions not met and only one free slot' do
    given_i_am_signed_in_with_one_login
    and_i_have_a_conditions_not_met_application_and_one_free_slot_to_submit
    when_i_visit_my_applications
    then_i_can_see_i_have_one_choice_left
    given_i_have_a_draft_application
    when_i_submit_a_new_application
    then_i_can_see_my_application_has_been_successfully_submitted
    when_i_click('Back to your applications')
    and_i_am_unable_to_add_any_further_choices
  end

  def and_i_have_a_conditions_not_met_application_and_one_free_slot_to_submit
    current_candidate.current_application.destroy!
    application_form = create(:application_form, :completed, :with_degree, candidate: current_candidate)
    create(:application_choice, :awaiting_provider_decision, application_form:)
    create(:application_choice, :awaiting_provider_decision, application_form:)
    create(:application_choice, :awaiting_provider_decision, application_form:)
    create(:application_choice, :conditions_not_met, application_form:)
  end

  def given_i_have_a_draft_application
    @application_choice = create(:application_choice, :unsubmitted, application_form: current_candidate.current_application)
  end

  def when_i_submit_a_new_application
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'
  end

  def then_i_can_see_i_have_one_choice_left
    expect(page).to have_content 'You can add 1 more application'
  end

  def and_i_am_unable_to_add_any_further_choices
    expect(page).to have_content 'You cannot add any more applications.'
  end

  def when_i_click(button)
    click_link_or_button button
  end
end
