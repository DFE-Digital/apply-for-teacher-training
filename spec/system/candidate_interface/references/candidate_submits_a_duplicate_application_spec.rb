require 'rails_helper'

RSpec.feature 'Submitting an application', :continuous_applications do
  include CandidateHelper

  it 'Candidate submits complete application' do
    given_i_am_signed_in
    and_i_have_completed_my_first_application

    when_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted

    when_i_am_signed_in_using_a_new_account
    and_i_complete_a_second_duplicate_application
    and_the_duplicate_matching_service_runs
    then_i_can_see_a_warning_message
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_am_signed_in_using_a_new_account
    @current_candidate = create(:candidate)
    create_and_sign_in_candidate
  end

  def and_i_have_completed_my_first_application
    candidate_completes_application_form
  end

  def and_i_complete_a_second_duplicate_application
    candidate_completes_application_form
  end

  def and_i_submit_the_application
    candidate_submits_application
  end
  alias_method :when_i_submit_the_application, :and_i_submit_the_application

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'
  end

  def and_the_duplicate_matching_service_runs
    UpdateDuplicateMatches.new.save!
    DuplicateMatch.first.candidates.each { |candidate| candidate.update!(submission_blocked: true) }
  end

  def then_i_can_see_a_warning_message
    visit candidate_interface_continuous_applications_details_path
    expect(page).to have_content('You’ve created more than one account.')
    expect(page).not_to have_button('Check and submit')
  end
end
