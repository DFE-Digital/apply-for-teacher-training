require 'rails_helper'

RSpec.feature 'Candidate attempts to submit their application without valid references', continuous_applications: false do
  include CandidateHelper

  it 'The candidate tries to complete application without entering references' do
    given_i_complete_my_application
    and_i_have_zero_references
    when_i_submit_my_application
    then_i_cannot_proceed
    when_i_complete_my_references
    then_i_can_proceed
  end

  def given_i_complete_my_application
    create_and_sign_in_candidate
    candidate_completes_application_form(with_referees: false)
  end

  def and_i_have_zero_references
    current_candidate.current_application.application_references.each(&:destroy)
  end

  def when_i_submit_my_application
    click_link 'Check and submit your application'
    click_link t('continue')
  end

  def then_i_cannot_proceed
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('References not marked as complete')
  end

  def when_i_complete_my_references
    create(:reference, :not_requested_yet, application_form: current_candidate.current_application)
    create(:reference, :not_requested_yet, application_form: current_candidate.current_application)
    current_candidate.current_application.update!(references_completed: true)
    visit candidate_interface_application_form_path
  end

  def then_i_can_proceed
    click_link 'Check and submit your application'
    click_link t('continue')

    expect(page).to have_content('Send application to training providers')
  end
end
