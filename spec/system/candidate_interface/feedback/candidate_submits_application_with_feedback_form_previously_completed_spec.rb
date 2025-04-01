require 'rails_helper'

RSpec.describe 'Candidate submits application with feedback form previously completed' do
  include CandidateHelper
  before do
    FeatureFlag.activate(:candidate_preferences)
  end

  it 'Candidate submits application, skips feedback and goes straight to the application dashboard' do
    given_i_complete_my_application
    and_the_feedback_form_was_previously_submitted
    then_i_submit_my_application
    then_i_do_not_see_the_feedback_form
    and_i_see_the_application_dashboard_and_success_message
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_the_feedback_form_was_previously_submitted
    current_application = current_candidate.current_application
    current_application.update!(feedback_form_complete: true)
  end

  def then_i_submit_my_application
    candidate_submits_application
  end

  def then_i_do_not_see_the_feedback_form
    expect(page).to have_no_content(t('page_titles.your_feedback'))
    expect(page).to have_no_content('How satisfied are you with this service? (optional)')
  end

  def and_i_see_the_application_dashboard_and_success_message
    expect(page).to have_current_path(candidate_interface_share_details_path)
    expect(page).to have_content('Application submitted')
  end
end
