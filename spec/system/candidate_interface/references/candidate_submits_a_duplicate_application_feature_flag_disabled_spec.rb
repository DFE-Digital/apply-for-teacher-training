require 'rails_helper'

RSpec.feature 'Submitting an application' do
  include CandidateHelper

  around do |example|
    old_references = CycleTimetable.apply_opens(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR)
    Timecop.freeze(old_references) { example.run }
  end

  it 'Candidate submits complete application' do
    given_the_new_reference_flow_feature_flag_is_off

    given_i_am_signed_in
    and_i_have_completed_my_first_application

    when_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted

    when_i_am_signed_in_using_a_new_account
    and_i_complete_a_second_duplicate_application
    and_the_duplicate_matching_service_runs
    then_i_can_see_a_warning_message
  end

  def given_the_new_reference_flow_feature_flag_is_off
    FeatureFlag.deactivate(:new_references_flow)
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
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
    click_link t('continue')
  end
  alias_method :when_i_submit_the_application, :and_i_submit_the_application

  def then_i_can_see_my_application_has_been_successfully_submitted
    click_link t('continue')

    # What is your sex?
    choose 'Prefer not to say'
    click_button t('continue')

    # Are you disabled?
    choose 'Prefer not to say'
    click_button t('continue')

    # What is your ethnic group?
    choose 'Prefer not to say'
    click_button t('continue')

    # Review page
    click_link t('continue')

    # Is there anything else you would like to tell us about your application?
    choose 'No'
    click_button 'Send application'

    # Your feedback
    click_button 'Continue'
    expect(page).to have_content 'Application successfully submitted'
  end

  def and_the_duplicate_matching_service_runs
    UpdateDuplicateMatches.new.save!
    DuplicateMatch.first.candidates.each { |candidate| candidate.update!(submission_blocked: true) }
  end

  def then_i_can_see_a_warning_message
    visit candidate_interface_application_form_path
    expect(page).to have_content('You’ve created more than one account.')
    expect(page).not_to have_button('Check and submit')
  end
end
