require 'rails_helper'

# This isn't a state that should ordinarily be allowed by the system, but if a
# candidate somehow ends up with more than two references selected, we handle
# it defensively so that we don't send more than the permitted number of
# references to providers.
RSpec.feature 'Handle applications with too many selected references' do
  include CandidateHelper

  scenario 'Candidate tries to submit an application with too many references' do
    given_the_reference_selection_feature_flag_is_active
    and_i_have_a_completed_application_with_more_than_two_selected_references

    when_i_try_to_submit_my_application
    then_i_see_an_error_message
    and_my_application_is_not_submitted
  end

  def given_the_reference_selection_feature_flag_is_active
    FeatureFlag.activate(:reference_selection)
  end

  def and_i_have_a_completed_application_with_more_than_two_selected_references
    create_and_sign_in_candidate
    candidate_completes_application_form # Including two reference selections
    create(:reference, :feedback_provided, selected: true, application_form: @application)
    visit candidate_interface_application_form_path
  end

  def when_i_try_to_submit_my_application
    click_link 'Check and submit'
    click_link 'Continue'
  end

  def then_i_see_an_error_message
    within('.govuk-error-summary') do
      expect(page).to have_content 'You need to have exactly 2 references selected before submitting your application'
    end
  end

  def and_my_application_is_not_submitted
    expect(@application.submitted?).to eq false
  end
end
