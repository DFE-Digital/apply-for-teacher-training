require 'rails_helper'

RSpec.feature 'Submitting a duplicate application' do
  include CandidateHelper

  before { given_courses_exist }

  scenario 'Candidate tries to submit an application and the submission is blocked' do
    given_i_have_an_account_submission_blocked
    and_i_am_signed_in
    when_i_try_to_submit_an_application
    then_i_can_see_an_interstitial_page_that_i_cant_submit
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate(candidate: @candidate)
  end

  def given_i_have_an_account_submission_blocked
    @candidate = create(:candidate, submission_blocked: true)
    @application_form = create(:application_form, :completed, candidate: @candidate, submitted_at: nil)
  end

  def when_i_try_to_submit_an_application
    candidate_adds_a_draft_application
    click_link_or_button 'Review application'
  end

  def then_i_can_see_an_interstitial_page_that_i_cant_submit
    expect(page).to have_content('You’ve created more than one account.')
    expect(page).to have_content('You can apply for up to 4 courses at a time.')
    expect(page).to have_no_button('Check and submit')
  end
end
