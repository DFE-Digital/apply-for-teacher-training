require 'rails_helper'

RSpec.feature 'Submitting an application' do
  include CandidateHelper

  scenario 'Candidate submits complete application' do
    given_i_am_signed_in
    and_i_have_completed_my_application_except_references
    then_i_can_see_references_are_incomplete

    when_i_have_added_references
    then_i_can_see_references_are_in_progress
    when_i_submit_the_application
    then_i_get_an_error_about_not_having_enough_references

    when_most_of_my_references_have_been_provided
    then_the_copy_is_updated
    and_i_submit_the_application
    then_i_get_an_error_about_not_selecting_enough_references

    when_i_select_my_references
    and_leave_the_references_section_incomplete
    and_i_submit_the_application
    then_i_get_an_error_about_not_marking_the_references_section_complete

    when_i_mark_the_references_section_complete
    then_i_can_see_the_references_section_is_complete
    when_i_submit_the_application
    then_i_can_see_my_application_has_been_successfully_submitted
    and_any_outstanding_reference_requests_are_cancelled
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
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
    expect(page).to have_content('It takes 8 days to get a reference on average. You can request as many references as you like to increase the chances of getting 2 quickly.')
    within(all('.govuk-list')[0]) do
      expect(page).to have_content("#{@reference1.name}: Awaiting response")
      expect(page).to have_content("#{@reference2.name}: Awaiting response")
      expect(page).to have_content("#{@reference3.name}: Awaiting response")
      expect(page).to have_content("#{@reference4.name}: Awaiting response")
    end
  end

  def then_i_can_see_references_are_incomplete
    expect(page).to have_content('It takes 8 days to get a reference on average. You can request as many references as you like to increase the chances of getting 2 quickly.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content('Cannot start yet')
    end
  end

  def then_i_can_see_the_references_section_is_complete
    visit candidate_interface_application_form_path
    expect(page).not_to have_content('You have enough references to send your application to training providers.')
    within(all('.govuk-list')[0]) do
      expect(page).to have_content("#{@reference1.name}: Reference selected")
      expect(page).to have_content("#{@reference2.name}: Reference selected")
      expect(page).to have_content("#{@reference3.name}: Reference received")
      expect(page).to have_content("#{@reference4.name}: Awaiting response")
    end

    within(all('.app-task-list')[1]) do
      expect(page).to have_content('Complete')
    end
  end

  def and_i_submit_the_application
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
    click_link t('continue')
  end
  alias_method :when_i_submit_the_application, :and_i_submit_the_application

  def then_i_get_an_error_about_not_having_enough_references
    error_summary = 'References not marked as complete'
    link_text = 'You need to receive at least 2 references'

    within '.govuk-error-summary' do
      expect(page).to have_content error_summary
    end

    within '#incomplete-references_selected-error' do
      expect(page).to have_content link_text
    end
  end

  def then_i_get_an_error_about_not_selecting_enough_references
    error_summary = 'References not marked as complete'
    link_text = 'You need to select 2 references'

    within '.govuk-error-summary' do
      expect(page).to have_content error_summary
    end

    within '#incomplete-references_selected-error' do
      expect(page).to have_content link_text
    end
  end

  def then_i_get_an_error_about_not_marking_the_references_section_complete
    error_summary = 'References not marked as complete'
    link_text = 'Complete your references'

    within '.govuk-error-summary' do
      expect(page).to have_content error_summary
    end

    within '#incomplete-references_selected-error' do
      expect(page).to have_content link_text
    end
  end

  def when_most_of_my_references_have_been_provided
    receive_references
    SubmitReference.new(reference: @reference3).save!
  end

  def then_the_copy_is_updated
    visit candidate_interface_application_form_path
    expect(page).to have_content('You have enough references to send your application to training providers.')
  end

  def when_i_select_my_references
    click_link 'You need to select 2 references'
    application_form = ApplicationForm.last
    first_reference = application_form.application_references.first
    second_reference = application_form.application_references.second
    check first_reference.name
    check second_reference.name
    click_button t('save_and_continue')
  end

  def and_leave_the_references_section_incomplete
    choose 'No, I’ll come back to it later'
    click_button t('save_and_continue')
  end

  def when_i_mark_the_references_section_complete
    click_link 'Complete your references'

    expect(page).not_to have_content 'References not marked as complete'
    expect(page).to have_content @reference1.name
    expect(page).to have_content @reference2.name

    choose 'Yes, I have completed this section'
    click_button t('save_and_continue')
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
