require 'rails_helper'

RSpec.feature 'Entering their equality and diversity information' do
  include CandidateHelper

  scenario 'Candidate submits equality and diversity information' do
    given_i_am_signed_in
    and_the_equality_and_diversity_feature_flag_is_active
    and_i_have_an_application_form_that_is_ready_to_submit
    and_i_am_on_the_review_page

    when_i_click_on_continue
    then_i_see_the_equality_and_diversity_page

    when_i_choose_not_to_complete_equality_and_diversity
    then_i_can_submit_my_application
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_equality_and_diversity_feature_flag_is_active
    FeatureFlag.activate('offer_declined_provider_emails')
  end

  def and_i_have_an_application_form_that_is_ready_to_submit
    @application = create(
      :completed_application_form,
      :with_completed_references,
      candidate: @current_candidate,
      submitted_at: nil,
      references_count: 2,
      with_gces: true,
    )
  end

  def and_i_am_on_the_review_page
    visit candidate_interface_application_review_path
  end

  def when_i_click_on_continue
    click_link 'Continue'
  end

  def then_i_see_the_equality_and_diversity_page
    expect(page).to have_content('Equality and diversity')
  end

  def when_i_choose_not_to_complete_equality_and_diversity
    click_link 'Continue without completing questionnaire'
  end

  def then_i_can_submit_my_application
    expect(page).to have_content('Submit application')
  end
end
