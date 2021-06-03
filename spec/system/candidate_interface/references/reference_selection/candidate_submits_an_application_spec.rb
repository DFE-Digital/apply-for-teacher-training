require 'rails_helper'

RSpec.feature 'Submitting an application' do
  include CandidateHelper

  scenario 'Candidate submits complete application' do
    given_i_am_signed_in
    and_the_reference_selection_feature_flag_is_active
    and_i_have_completed_my_application_except_references
    then_i_can_see_references_are_incomplete

    when_i_have_added_references
    then_i_can_see_references_are_in_progress
    when_i_submit_the_application
    then_i_get_an_error_about_my_references

    when_most_of_my_references_have_been_provided
    and_i_submit_the_application
    then_i_get_an_error_about_my_references
    when_i_have_selected_references
    then_i_can_see_the_references_section_is_complete
    when_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted
    and_any_outstanding_reference_requests_are_cancelled
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_reference_selection_feature_flag_is_active
    FeatureFlag.activate('reference_selection')
  end

  def and_i_have_completed_my_application_except_references
    candidate_completes_application_form(with_referees: false)
  end

  def when_i_have_added_references
    @reference1 = create(:reference, :feedback_requested, application_form: current_candidate.current_application)
    @reference2 = create(:reference, :feedback_requested, application_form: current_candidate.current_application)
    @reference3 = create(:reference, :feedback_requested, application_form: current_candidate.current_application)
    @reference4 = create(:reference, :feedback_requested, application_form: current_candidate.current_application)
  end

  def then_i_can_see_references_are_in_progress
    visit candidate_interface_application_form_path
    expect(page).to have_content('You have to get 2 references back before you can send your application to training providers.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content("#{@reference1.name}: Awaiting response")
      expect(page).to have_content("#{@reference2.name}: Awaiting response")
      expect(page).to have_content("#{@reference3.name}: Awaiting response")
      expect(page).to have_content("#{@reference4.name}: Awaiting response")
    end
  end

  def then_i_can_see_references_are_incomplete
    expect(page).to have_content('You have to get 2 references back before you can send your application to training providers.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content('Incomplete')
    end
  end

  def then_i_can_see_the_references_section_is_complete
    visit candidate_interface_application_form_path
    expect(page).not_to have_content('You have to get 2 references back before you can send your application to training providers.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content('Complete')
      expect(page).to have_content("#{@reference1.name}: Reference given")
      expect(page).to have_content("#{@reference2.name}: Reference given")
      expect(page).to have_content("#{@reference3.name}: Reference given")
      expect(page).to have_content("#{@reference4.name}: Awaiting response")
    end
  end

  def and_i_submit_the_application
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
    click_link t('continue')
  end
  alias_method :when_i_submit_the_application, :and_i_submit_the_application

  def then_i_get_an_error_about_my_references
    error = 'References not marked as complete'

    within '.govuk-error-summary' do
      expect(page).to have_content error
    end

    within '#incomplete-references_selected-error' do
      expect(page).to have_content error
    end
  end

  def when_i_have_selected_references
    click_link 'You need to select 2 references'
    select_references_and_complete_section
  end

  def when_most_of_my_references_have_been_provided
    receive_references
    SubmitReference.new(reference: @reference3).save!
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    choose 'No'
    click_button t('continue')
    choose 'No'
    click_button 'Send application'
    click_button 'Continue'
    expect(page).to have_content 'Application successfully submitted'
  end

  def and_any_outstanding_reference_requests_are_cancelled
    expect(@reference1.reload).to be_feedback_provided
    expect(@reference1).to be_selected
    expect(@reference2.reload).to be_feedback_provided
    expect(@reference2).to be_selected
    expect(@reference3.reload).to be_feedback_provided
    expect(@reference3).not_to be_selected

    expect(@reference4.reload).to be_cancelled
  end

private

  def application
    current_candidate.current_application
  end

  def provider
    application.application_choices.first.provider
  end
end
