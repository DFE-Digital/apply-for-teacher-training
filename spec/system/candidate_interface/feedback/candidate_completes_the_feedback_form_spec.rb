require 'rails_helper'

RSpec.describe 'Candidate feedback form' do
  include CandidateHelper

  scenario 'Candidate completes the feedback form' do
    given_i_complete_and_submit_my_application
    then_i_should_see_the_feedback_form

    when_i_choose_very_satisfied
    and_i_make_a_suggestion
    and_click_continue
    then_i_see_the_application_dashboard_and_success_message
    and_my_feedback_should_reflect_my_inputs
  end

  def given_i_complete_and_submit_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def then_i_should_see_the_feedback_form
    expect(page).to have_content(t('page_titles.your_feedback'))
    expect(page).to have_content('How satisfied are you with this service? (optional)')
  end

  def when_i_choose_very_satisfied
    choose 'Very satisfied'
  end

  def and_i_make_a_suggestion
    fill_in 'How could we improve this service?', with: 'More rainbows and unicorns'
  end

  def and_click_continue
    click_button 'Continue'
  end

  def then_i_see_the_application_dashboard_and_success_message
    expect(page).to have_current_path(candidate_interface_application_complete_path)
    expect(page).to have_content('Application successfully submitted')
    expect(page).to have_content('You will get an email when something changes.')
  end

  def and_my_feedback_should_reflect_my_inputs
    expect(ApplicationForm.last.feedback_satisfaction_level).to eq('very_satisfied')
  end
end
