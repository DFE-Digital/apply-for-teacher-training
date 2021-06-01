require 'rails_helper'

RSpec.feature 'Submitting an application' do
  include CandidateHelper

  before { FeatureFlag.deactivate(:reference_selection) }

  scenario 'Candidate submits complete application' do
    given_i_am_signed_in
    and_i_have_completed_my_application
    then_i_can_see_references_are_incomplete

    when_i_have_added_references
    then_i_can_see_references_are_in_progress
    and_i_submit_the_application
    then_i_get_an_error_about_my_references
    when_my_references_have_been_provided
    then_i_can_see_references_are_complete
    and_i_submit_the_application

    then_i_can_see_my_application_has_been_successfully_submitted
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_completed_my_application
    candidate_completes_application_form(with_referees: false)
  end

  def then_i_can_see_references_are_incomplete
    expect(page).to have_content('You have to get 2 references back before you can send your application to training providers.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content('Incomplete')
      expect(page).to have_link('Add your references')
    end
  end

  def then_i_can_see_references_are_in_progress
    visit candidate_interface_application_form_path
    expect(page).to have_content('You have to get 2 references back before you can send your application to training providers.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content('In progress')
      expect(page).to have_link('Manage your references')
      expect(page).to have_content("#{@reference1.name}: Not requested yet")
      expect(page).to have_content("#{@reference2.name}: Not requested yet")
    end
  end

  def then_i_can_see_references_are_complete
    visit candidate_interface_application_form_path
    expect(page).not_to have_content('You have to get 2 references back before you can send your application to training providers.')
    within(all('.app-task-list')[1]) do
      expect(page).to have_content('Complete')
      expect(page).to have_link('Review your references')
      expect(page).to have_content("#{@reference1.name}: Reference given")
      expect(page).to have_content("#{@reference2.name}: Reference given")
    end
  end

  def when_i_have_added_references
    @reference1 = create(:reference, :not_requested_yet, application_form: current_candidate.current_application)
    @reference2 = create(:reference, :not_requested_yet, application_form: current_candidate.current_application)
  end

  def and_i_submit_the_application
    visit candidate_interface_application_form_path
    click_link 'Check and submit your application'
    click_link t('continue')
  end

  def then_i_get_an_error_about_my_references
    within '.govuk-error-summary' do
      expect(page).to have_content 'You need 2 references before you can submit your application'
    end
  end

  def when_my_references_have_been_provided
    application.application_references.each do |reference|
      SubmitReference.new(reference: reference).save!
    end
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    choose 'No'
    click_button t('continue')
    choose 'No'
    click_button 'Send application'
  end

private

  def application
    current_candidate.current_application
  end

  def provider
    application.application_choices.first.provider
  end
end
