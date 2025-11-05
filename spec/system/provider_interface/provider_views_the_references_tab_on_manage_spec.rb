require 'rails_helper'

RSpec.describe 'Provider views an application in new cycle' do
  include CandidateHelper
  include CourseOptionHelpers
  include DfESignInHelpers

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(2023))
  end

  scenario 'Provider views the new references tab' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_organisation_has_applications
    and_i_sign_in_to_the_provider_interface
    then_i_see_the_applications_from_my_organisation

    when_i_click_on_an_application
    then_i_am_on_the_application_view_page

    when_i_click_on_the_references_tab
    then_i_see_the_candidates_references

    when_the_candidate_accepts_an_offer
    and_i_revisit_references
    then_i_see_the_reference_requested_section

    when_the_candidate_receives_a_reference
    and_i_revisit_references
    then_i_see_the_reference_feedback
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in

    provider_user = provider_user_exists_in_apply_database
    @provider = provider_user.providers.first
  end

  def and_my_organisation_has_applications
    course_option = course_option_for_provider(provider: @provider)

    @my_provider_choice = create(:application_choice, :awaiting_provider_decision,
                                 :with_completed_application_form,
                                 status: 'awaiting_provider_decision',
                                 course_option:)

    @my_provider_choice.application_form.update(recruitment_cycle_year: 2023)
    @my_provider_choice.application_form.application_references.update(feedback_status: 'feedback_requested')
  end

  def then_i_see_the_applications_from_my_organisation
    expect(page).to have_title 'Applications (1)'
    expect(page).to have_content 'Applications (1)'
    expect(page).to have_content @my_provider_choice.application_form.full_name
  end

  def when_i_click_on_an_application
    click_link_or_button @my_provider_choice.application_form.full_name
  end

  def then_i_am_on_the_application_view_page
    expect(page).to have_content @my_provider_choice.id

    expect(page).to have_content @my_provider_choice.application_form.full_name
  end

  def when_i_click_on_the_references_tab
    click_link_or_button 'References'
  end

  def then_i_see_the_candidates_references
    references = @my_provider_choice.application_form.application_references.creation_order
    link = page.find_link('References', class: 'app-tab-navigation__link')
    expect(link['aria-current']).to eq('page')

    expect(page).to have_content pre_offer_message

    expect(page).to have_element(:h3, text: references.first.name, class: 'app-summary-card__title')
    expect(page).to have_element(:h3, text: references.second.name, class: 'app-summary-card__title')
  end

  def when_the_candidate_accepts_an_offer
    @my_provider_choice.update(status: 'pending_conditions')
  end

  def when_the_candidate_receives_a_reference
    @my_provider_choice.application_form.application_references.creation_order.first.update(feedback_status: 'feedback_provided')
  end

  def and_i_revisit_references
    click_link_or_button 'References'
  end

  def then_i_see_the_reference_requested_section
    expect(page).to have_no_content pre_offer_message
    expect(page).to have_content 'Requested references'
    expect(page).to have_content 'The candidate has requested 2 references.'
    expect(page).to have_no_content @my_provider_choice.application_form.application_references.creation_order.first.feedback
  end

  def then_i_see_the_reference_feedback
    expect(page).to have_content @my_provider_choice.application_form.application_references.creation_order.first.feedback
  end

  def pre_offer_message
    'References will be requested when the candidate accepts an offer. Do not contact these people before then without permission from the candidate.'
  end
end
